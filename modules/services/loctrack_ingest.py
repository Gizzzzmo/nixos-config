#!/usr/bin/env python3
"""Location-sample ingest endpoint for the Garmin Fenix 7 passive location tracker.

A Connect IQ background process POSTs batches of CSV samples here as a
urlencoded form body (the SDK's REQUEST_CONTENT_TYPE_URL_ENCODED contract;
Content-Type: application/x-www-form-urlencoded):

    data=<urlencoded csv>

with rows (no header):

    ts,lat_e7,lon_e7,acc_m,fix_source,in_activity,steps_delta,hr,hr_baseline,battery_pct,displacement_m,interval_next_s
    1789000000,494520300,110766100,8,1,1,142,98,48,71,312,300
    ...

A bare CSV body (no "data=" prefix) is also accepted, e.g. for curl
testing. ts/lat_e7/lon_e7 are required; all other fields may be empty.
Every *parsed* row (new or duplicate) advances accepted_through_ts, so a
re-sent batch whose rows are all already stored still gets acked and the
watch can trim its buffer (a resend-safe ack). Accepted rows are appended
to passive-location.jsonl as JSON (lat/lon converted to decimal degrees);
duplicates (ts,lat_e7,lon_e7) are not stored again. Responses are JSON:
    200 {"accepted": n, "duplicates": n, "rejected": n, "accepted_through_ts": max_ts|null}
    401 bad/missing token · 400 malformed CSV · 405 wrong method

Runs on 127.0.0.1:8443 behind the nginx reverse proxy (public path /location/ingest).
Auth token: env LOCATION_INGEST_TOKEN, else token file next to this script
(token file, chmod 600). Stdlib only.
"""

import json
import os
import secrets
import sys
import threading
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs

BASE = Path("/mnt/storagebox-loctrack").resolve()
DATA = BASE / "passive-location.jsonl"
SEEN = BASE / "seen_index.jsonl"
TOKEN_FILE = BASE / "token"
PORT = int(os.environ.get("INGEST_PORT", "8443"))

COLUMNS = [
    "ts",
    "lat_e7",
    "lon_e7",
    "acc_m",
    "fix_source",
    "in_activity",
    "steps_delta",
    "hr",
    "hr_baseline",
    "battery_pct",
    "displacement_m",
    "interval_next_s",
]
REQUIRED = ("ts", "lat_e7", "lon_e7")
INT_FIELDS = set(COLUMNS) - {"ts"}  # all except ts are nullable ints
NULLABLE = INT_FIELDS

_lock = threading.Lock()
_seen = set()
_seen_loaded = False


def log(msg):
    sys.stderr.write(f"{datetime.now(timezone.utc).isoformat()} {msg}\n")
    sys.stderr.flush()


def load_token():
    tok = os.environ.get("LOCATION_INGEST_TOKEN")
    if tok:
        return tok.strip()
    if TOKEN_FILE.exists():
        return TOKEN_FILE.read_text().strip()
    tok = secrets.token_urlsafe(32)
    TOKEN_FILE.write_text(tok + "\n")
    os.chmod(TOKEN_FILE, 0o600)
    log(f"generated new token at {TOKEN_FILE}")
    return tok


TOKEN = load_token()


def _load_seen():
    global _seen, _seen_loaded
    if _seen_loaded:
        return
    if SEEN.exists():
        for line in SEEN.read_text().splitlines():
            try:
                _seen.add(tuple(json.loads(line)))
            except Exception:
                pass
    _seen_loaded = True


def _save_seen(key):
    with SEEN.open("a") as f:
        f.write(json.dumps(list(key)) + "\n")


def parse_csv(body: str):
    """Return (rows, n_rejected, error). Rows are dicts ready for jsonl."""
    lines = [l for l in body.strip().splitlines() if l.strip()]
    if not lines:
        return [], 0, "empty body"
    # header is optional but if present must match
    if lines[0].strip().startswith("ts,"):
        lines = lines[1:]
    rows, rejected = [], 0
    for ln in lines:
        parts = [p.strip() for p in ln.split(",")]
        if len(parts) > len(COLUMNS):
            log(f"rejected because {len(parts)=} > {len(COLUMNS)=}")
            rejected += 1
            continue
        if len(parts) < len(COLUMNS):
            parts += [""] * (len(COLUMNS) - len(parts))  # pad trailing empties
        raw = dict(zip(COLUMNS, parts))
        # required fields
        try:
            ts = int(raw["ts"])
            lat_e7 = int(raw["lat_e7"])
            lon_e7 = int(raw["lon_e7"])
        except ValueError as v:
            log(f"rejected because {v}")
            rejected += 1
            continue
        if not (
            -900000000 <= lat_e7 <= 900000000 and -1800000000 <= lon_e7 <= 1800000000
        ):
            log(f"rejected because bad coords: {lat_e7=}, {lon_e7=}")
            rejected += 1
            continue
        row = {"ts": ts, "lat": lat_e7 / 1e7, "lon": lon_e7 / 1e7}
        for col in NULLABLE:
            v = raw[col]
            if v == "":
                row[col] = None
            else:
                try:
                    row[col] = int(float(v))
                except ValueError:
                    row[col] = None
        rows.append(row)
    return rows, rejected, None


class Handler(BaseHTTPRequestHandler):
    server_version = "location-ingest/1.0"

    def _json(self, code, obj):
        payload = json.dumps(obj).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def _authed(self):
        h = self.headers.get("Authorization", "")
        if not h.startswith("Bearer "):
            return False
        supplied = h[len("Bearer ") :].strip()
        return secrets.compare_digest(supplied, TOKEN)

    def do_GET(self):
        self._json(405, {"error": "POST only"})

    def do_POST(self):
        if self.path.rstrip("/") != "/ingest":
            self._json(404, {"error": "not found"})
            return
        if not self._authed():
            self._json(401, {"error": "unauthorized"})
            return
        try:
            length = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            length = 0
        if length <= 0 or length > 1_000_000:
            self._json(400, {"error": "bad content-length"})
            return
        body = self.rfile.read(length).decode("utf-8", "replace")

        # The watch form-encodes the CSV as "data=<urlencoded csv>" (the
        # SDK's REQUEST_CONTENT_TYPE_URL_ENCODED contract). Be lenient and
        # also accept a bare CSV body (no data= prefix), e.g. for curl.
        if body.startswith("data="):
            params = parse_qs(body, keep_blank_values=True)
            csv_text = params.get("data", [""])[0]
        else:
            csv_text = body
        log(f"request body:\n{body}\n")

        rows, rejected, err = parse_csv(csv_text)
        if err:
            self._json(400, {"error": err})
            return

        accepted = 0
        duplicates = 0
        max_ts = None
        with _lock:
            _load_seen()
            with DATA.open("a") as f:
                for r in rows:
                    key = (r["ts"], round(r["lat"] * 1e7), round(r["lon"] * 1e7))
                    if key in _seen:
                        duplicates += 1
                    else:
                        r["received_at"] = datetime.now(timezone.utc).isoformat()
                        f.write(json.dumps(r, ensure_ascii=False) + "\n")
                        _seen.add(key)
                        _save_seen(key)
                        accepted += 1
                    # Every parsed row (new or duplicate) advances the ack:
                    # duplicates are already durably stored, so acknowledging
                    # them lets the watch trim and prevents a resend loop
                    # when a batch is replayed after a lost response.
                    if max_ts is None or r["ts"] > max_ts:
                        max_ts = r["ts"]
        log(
            f"{self.client_address[0]} rows={len(rows)} accepted={accepted} "
            f"duplicates={duplicates} rejected={rejected}"
        )
        self._json(
            200,
            {
                "accepted": accepted,
                "duplicates": duplicates,
                "rejected": rejected,
                "accepted_through_ts": max_ts,
            },
        )

    def log_message(self, format, *args):  # silence default access log
        pass


def main():
    _load_seen()
    srv = ThreadingHTTPServer(("127.0.0.1", PORT), Handler)
    log(
        f"listening on 127.0.0.1:{PORT}, token source: "
        f"{'env' if os.environ.get('LOCATION_INGEST_TOKEN') else TOKEN_FILE}"
    )
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
