#!/bin/sh
set -eu

mkdir -p build

fpc -v0sw -obuild/arschipel src/arschipel.pas
