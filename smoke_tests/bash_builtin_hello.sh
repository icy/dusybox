#!/usr/bin/env bash

# Purpose : Smoke tests
# Author  : Ky-Anh Huynh
# License : MIT
# Date    : 2017 Oct 21st

set -xe

enable -f output/libdz_hello.so dz_hello
type -a dz_hello | grep builtin
dz_hello | grep "Hello"
dz_hello Foo bar | grep "Foo bar"
enable -d dz_hello
dz_hello 2>&1 | grep 'command not found'
