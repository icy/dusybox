#!/usr/bin/env bash

# Purpose : Smoke tests
# Author  : Ky-Anh Huynh
# License : MIT
# Date    : 2017 Oct 21st

set -e

enable -f output/libdz_hello.so dz_hello
type -a dz_hello | grep builtin

dz_hello | grep "Hello"
dz_hello Foo bar | grep "Foo bar"

echo >&2 ":: Invoke 100k times..."
time {
  for i in {1..10000}; do dz_hello Test >/dev/null; done
}

enable -d dz_hello
dz_hello 2>&1 | grep 'command not found'
