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

echo >&2 ":: [dz_hello(loaded)] Invoke 1M times..."
time {
  for i in {1..1000000}; do dz_hello Test >/dev/null; done
}

echo >&2 ":: [echo] Invoke 1M times..."
time {
  for i in {1..1000000}; do echo Test >/dev/null; done
}

# SLOW! # echo >&2 ":: [/usr/bin/echo] Invoke 1M times..."
# SLOW! # time {
# SLOW! #   for i in {1..1000000}; do /usr/bin/echo Test >/dev/null; done
# SLOW! # }

enable -d dz_hello
dz_hello 2>&1 | grep 'command not found'
