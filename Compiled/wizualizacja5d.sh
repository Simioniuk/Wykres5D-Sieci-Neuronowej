#!/bin/sh
printf '\033c\033]0;%s\a' WizualizacjiaMultiWymiarowa
base_path="$(dirname "$(realpath "$0")")"
"$base_path/wizualizacja5d.x86_64" "$@"
