#!/bin/sh
set -eu

TARGS="arschipel"

clean() {
  rm -f -- *.o "$TARGS"
}

build() {
  for x in $TARGS.pas; do
    fpc -v0sw -O2 -Xs -Mfpc "$x"
  done
}

debug() {
  for x in $TARGS.pas; do
    fpc -vs -gl -Crtoi -Mfpc "$x"
  done
}

shift $((OPTIND - 1))

while getopts :cd opts; do
  case "${opts}" in
  c) clean ;;
  d) debug ;;
  \?) exit 1 ;;
  esac
done

if [ -z "${1:-}" ]; then
  build
fi

