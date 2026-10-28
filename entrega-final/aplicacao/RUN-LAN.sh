#!/bin/sh
# POSIX shell: Linux/macOS. Credentials come only from the process environment.
set -eu
umask 077
case $0 in
  */*) script_dir=${0%/*} ;;
  *) script_dir=. ;;
esac
script_dir=$(CDPATH= cd -P "$script_dir" && pwd)
if ! command -v node >/dev/null 2>&1; then
  printf '%s\n' 'Node.js nao encontrado no PATH. Instale uma versao LTS suportada (minimo tecnico: 18).' >&2
  exit 127
fi
exec node "$script_dir/LAN-SERVER.cjs" "$@"
