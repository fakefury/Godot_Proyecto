#!/bin/sh
printf '\033c\033]0;%s\a' Hit Mask Change
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Hit Mask Change.x86_64" "$@"
