#!/usr/bin/env bash
# Install the same open fonts for local builds, CI, and release previews.
set -euo pipefail
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
destination=${1:-fonts}
mkdir -p "$destination"
archive_dir=$(mktemp -d)
trap 'rm -rf "$archive_dir"' EXIT
while read -r digest archive; do
  [[ -z "$digest" || "$digest" == \#* ]] && continue
  curl -fLsS "https://mirrors.mit.edu/CTAN/fonts/$archive" -o "$archive_dir/$archive"
  (cd "$archive_dir" && printf '%s  %s\n' "$digest" "$archive" | sha256sum --check -)
  unzip -qo "$archive_dir/$archive" -d "$destination"
done < "$script_dir/fonts.sha256"
