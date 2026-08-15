#!/usr/bin/env bash
set -euo pipefail

# hf-hash - get SHA256 hash of a Hugging Face file without downloading
# Usage: hf-hash <resolve-url>
# Example: hf-hash https://huggingface.co/unsloth/Qwen3.6-27B-MTP-GGUF/resolve/main/Qwen3.6-27B-Q3_K_S.gguf

url="${1:?Usage: hf-hash <huggingface-resolve-url>}"

normalized="${url%/}"
model_id="${normalized#https://huggingface.co/}"
model_id="${model_id%/resolve/*}"
file_path="${normalized#*/resolve/*/}"

if [[ -z "$model_id" || -z "$file_path" ]]; then
  echo "Error: could not parse URL. Expected format: https://huggingface.co/{model}/resolve/{branch}/{path}" >&2
  exit 1
fi

branch="${normalized#*/resolve/}"
branch="${branch%%/*}"

data=$(curl -s "https://huggingface.co/api/models/${model_id}/tree/${branch}" | \
  jq --arg path "$file_path" '.[] | select(.path == $path)')

if [[ -z "$data" || "$data" == "null" ]]; then
  echo "Error: file not found in API response" >&2
  exit 1
fi

lfs_oid=$(jq -r '.lfs.oid // empty' <<< "$data")
xet_hash=$(jq -r '.xetHash // empty' <<< "$data")
sha256=$(jq -r '.sha256 // empty' <<< "$data")
size=$(jq -r '.lfs.size // .size // empty' <<< "$data")

hex_to_b64() {
  xxd -r -p <<< "$1" | base64 | tr -d '\n'
}

echo "Model:  $model_id"
echo "Branch: $branch"
echo "File:   $file_path"
[[ -n "$size" ]] && echo "Size:   $(numfmt --to=iec-i "$size" 2>/dev/null || echo "$size bytes")"

if [[ -n "$sha256" && "$sha256" != "null" ]]; then
  echo "SHA256: $sha256"
  echo "sha256-$(hex_to_b64 "$sha256")"
fi
if [[ -n "$lfs_oid" && "$lfs_oid" != "null" ]]; then
  echo "SHA256: $lfs_oid  (LFS OID)"
  echo "sha256-$(hex_to_b64 "$lfs_oid")"
fi
[[ -n "$xet_hash" && "$xet_hash" != "null" ]] && echo "sha256-$(hex_to_b64 "$xet_hash")  (XetHash)"

if [[ -z "$lfs_oid" && -z "$sha256" && -z "$xet_hash" ]]; then
  echo "No hashes found in API response" >&2
  exit 1
fi
