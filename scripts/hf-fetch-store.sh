#!/usr/bin/env bash
set -euo pipefail

# hf-fetch-store - download any Hugging Face file into the nix store.
#
# Two-step, resumable, so an interrupted run never loses progress (nix would
# discard a partial store output otherwise):
#   1. wget -c to a staging dir outside the store.
#   2. Verify the sha256, then `nix store add` it into the store.
#
# The added file lands at exactly the path a `fetchurl` with the same content
# hash + name would produce, so a later `nixos-rebuild` reuses it instead of
# re-downloading. Skips early if that path is already present.
#
# Usage: hf-fetch-store.sh [--out-dir DIR] <hf-resolve-url>
# Example:
#   hf-fetch-store.sh \
#     https://huggingface.co/gsrunion/Qwen3.6-35B-A3B-ROCmFP4-STRIX_LEAN-GGUF/resolve/main/Qwen3.6-35B-A3B-Q4_0_ROCMFP4_STRIX_LEAN.gguf

OUT_DIR="/tmp/hf-download"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o | --out-dir)
      OUT_DIR="$2"
      shift 2
      ;;
    -h | --help)
      sed -n '1,30p' "$0"
      exit 0
      ;;
    *)
      URL="$1"
      shift
      ;;
  esac
done

[[ -n "${URL:-}" ]] || { echo "Error: no URL given" >&2; exit 1; }

# ----- parse the resolve url into model id + file path -----------------------
normalized="${URL%/}"
model_id="${normalized#https://huggingface.co/}"
model_id="${model_id%/resolve/*}"
file_path="${normalized#*/resolve/*/}"
branch="${normalized#*/resolve/}"
branch="${branch%%/*}"

if [[ -z "$model_id" || -z "$file_path" ]]; then
  echo "Error: could not parse URL. Expected: https://huggingface.co/{model}/resolve/{branch}/{path}" >&2
  exit 1
fi

base_name="$(basename "$file_path")"

# ----- fetch metadata (sha256 via LFS OID) -----------------------------------
data=$(curl -s "https://huggingface.co/api/models/${model_id}/tree/${branch}" | \
  jq --arg path "$file_path" '.[] | select(.path == $path)')

if [[ -z "$data" || "$data" == "null" ]]; then
  echo "Error: file not found in API response" >&2
  exit 1
fi

lfs_oid=$(jq -r '.lfs.oid // empty' <<< "$data")
xet_hash=$(jq -r '.xetHash // empty' <<< "$data")
sha256=$(jq -r '.sha256 // empty' <<< "$data")
size=$(jq -r '.lfs.size // .size // 0' <<< "$data")

sha256_hex="${lfs_oid:-${xet_hash:-$sha256}}"
if [[ -z "$sha256_hex" ]]; then
  echo "Error: no sha256 hash available for this file" >&2
  exit 1
fi

echo "Model:  $model_id"
echo "File:   $file_path"
echo "Size:   $(numfmt --to=iec-i "$size" 2>/dev/null || echo "$size bytes")"
echo "SHA256: $sha256_hex"

# ----- convert hex sha256 to SRI ----------------------------------------------
hex_to_b64() { xxd -r -p <<< "$1" | base64 | tr -d '\n'; }
sri="sha256-$(hex_to_b64 "$sha256_hex")"

# ----- skip if already in the store -------------------------------------------
# Compute the exact fetchurl output path from hash + name (no download) and
# check whether that path is already a valid store object.
expected_path=$(
  nix --extra-experimental-features 'nix-command flakes' eval --impure --raw \
    --expr "with import <nixpkgs> {}; (pkgs.fetchurl { name = \"$base_name\"; hash = \"$sri\"; url = \"placeholder\"; }).outPath" \
    2>/dev/null || true
)

if [[ -n "$expected_path" ]] && nix path-info "$expected_path" >/dev/null 2>&1; then
  echo "already in store: $expected_path"
  exit 0
fi

echo "(not in store, downloading...)"

# ----- download to staging dir (resumable, outside the store) ----------------
mkdir -p "$OUT_DIR"
local_file="$OUT_DIR/$base_name"
wget -c --show-progress -O "$local_file" "$URL"

echo "Verifying hash..."
actual=$(sha256sum "$local_file" | awk '{print $1}')
if [[ "$actual" != "$sha256_hex" ]]; then
  echo "Error: hash mismatch after download" >&2
  echo "  expected: $sha256_hex" >&2
  echo "  actual:   $actual" >&2
  exit 1
fi

# ----- add to the nix store (idempotent) --------------------------------------
# --mode flat + default name gives the same path as fetchurl for this content.
store_path=$(nix store add --mode flat --name "$base_name" "$local_file")
echo "stored: $store_path"
echo "OK"
