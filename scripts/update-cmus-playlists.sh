#!/bin/sh

# create temporary directory
dir=$(mktemp -d)

for playlist_path in ~/Music/*.m3u; do
	playlist=$(basename "$playlist_path")
	sed "$playlist_path" -e "s|^Music/|$HOME/Music/|g" >"$dir/$playlist"
	echo "$playlist_path"
	echo "$dir/$playlist"
	echo pl-delete "$playlist" | cmus-remote
	echo pl-import "$dir/$playlist" | cmus-remote
done
