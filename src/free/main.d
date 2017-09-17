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
import std.conv;
public import dusybox.meminfo;

void main() {
  auto mem = meminfo;
  auto const MiB = 1024;

  auto default_output = [
    mem["MemTotal"],
    mem["MemUsed"],
    mem["MemFree"],
    mem["Shmem"],
    mem["Buffers"] + mem["Cached"],
    mem["MemAvailable"]
    ];

  auto percents = to!(float[])(default_output.dup);

  /*
  Sample output from `free -m` command.
  See also https://gitlab.com/procps-ng/procps/blob/master/free.c#L363
  */
  writefln("%-7s   %-(%11s%| %)", "", ["total", "user", "free", "shared", "buff/cache", "available"]);
  writefln("%-7s %-(%11s%| %)", "Mem (kB):", default_output);

  default_output[] /= MiB;
  writefln("%-7s %-(%11s%| %)", "Mem (mB):", default_output);

  default_output[] /= MiB;
  writefln("%-7s %-(%11s%| %)", "Mem (gB):", default_output);

  percents[] /= percents[0];
  percents[] *= 100;
  writefln("%-7s %-(%11.2f%| %)", "Mem  (%):", percents);
}
