#!/usr/bin/env rdmd

/*
  Purpose : Collect memory information (similar to `free`...)
  Author  : Ky-Anh Huynh
  Date    : 2017 Sep 04
  License : MIT
  FIXME   : This program may not wokr with your Linux Kernel :)
*/

import std.stdio;
import std.format;
public import dusybox.meminfo;

void main() {
  auto mem = meminfo;

  /*
  Sample output from `free -m` command.
  See also https://gitlab.com/procps-ng/procps/blob/master/free.c#L363

    $ free
                  total        used        free      shared  buff/cache   available
    Mem:       16337684     3283552     2857804      600292    10196328    12603728
    Swap:             0           0           0
  */
  writeln("              total        used        free      shared  buff/cache   available");
  writefln("%-7s %11s %11s %11s %11s %11s %11s",
    "Mem:",
    mem["MemTotal"],
    mem["MemUsed"],
    mem["MemFree"],
    mem["Shmem"],
    mem["Buffers"] + mem["Cached"],
    mem["MemAvailable"]
  );
}
