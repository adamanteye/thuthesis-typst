#!/usr/bin/env bash
set -euo pipefail

font_dir=${1:-fonts}
uup_arch=${UUP_ARCH:-amd64}
uup_search=${UUP_SEARCH:-Windows 11 24H2 $uup_arch}
uup_api=${UUP_API:-https://api.uupdump.net}

for cmd in curl jq 7z; do
	command -v "$cmd" >/dev/null || {
		printf 'error: %s not found\n' "$cmd" >&2
		exit 1
	}
done

printf 'WARNING: This downloads proprietary Microsoft Windows fonts for local licensed use only.\n'
read -r -p 'Confirm you hold a valid Windows license? [y/N] ' reply
[[ $reply == [yY] ]] || {
	printf 'Cancelled.\n'
	exit 2
}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

build_id=$(curl --proto '=https' --tlsv1.2 -fsSLG --retry 3 \
	--data-urlencode "search=$uup_search" --data-urlencode 'sortByDate=1' \
	"$uup_api/listid.php" |
	jq -er --arg a "$uup_arch" '[.response.builds[] | select(.arch == $a and .uuid)] | sort_by(.created) | last.uuid')
curl --proto '=https' --tlsv1.2 -fsSL --retry 3 "$uup_api/get.php?id=$build_id" -o "$tmp/files.json"

download() {
	local url re='^https?://[^/]+\.(dl\.delivery\.mp\.microsoft\.com|download\.windowsupdate\.com)/'
	url=$(jq -er --arg n "$1" '[.response.files | to_entries[] | select((.key | ascii_downcase) == ($n | ascii_downcase)) | .value.url][0] // error("not found: " + $n)' "$tmp/files.json")
	[[ $url =~ $re ]] || {
		printf 'error: unexpected URL: %s\n' "$url" >&2
		exit 1
	}
	printf 'Downloading %s...\n' "$1"
	curl --proto '=http,https' --tlsv1.2 -fL --retry 3 -C - "$url" -o "$2"
}

download "Microsoft-Windows-LanguageFeatures-Fonts-Hans-Package-$uup_arch.cab" "$tmp/hans.cab"
download 'Microsoft-Windows-Client-Desktop-Required-Package.ESD' "$tmp/base.esd"

mkdir -p "$font_dir" "$tmp/x"
7z x -y -o"$tmp/x" "$tmp/hans.cab" >/dev/null
7z e -y -o"$tmp/x" "$tmp/base.esd" '-ir!*/arial*.ttf' '-ir!*/cour*.ttf' '-ir!*/times*.ttf' '-ir!*/simsun.ttc' >/dev/null

for f in arial{,bd,i,bi}.ttf times{,bd,i,bi}.ttf cour{,bd,i,bi}.ttf simsun.ttc simhei.ttf simkai.ttf simfang.ttf; do
	src=$(find "$tmp/x" -type f -iname "$f" | sed -n '1p')
	[[ -n $src ]] || {
		printf 'error: missing font: %s\n' "$f" >&2
		exit 1
	}
	install -m 644 "$src" "$font_dir/$f"
done
printf 'Installed Windows fonts in %s.\n' "$font_dir"
