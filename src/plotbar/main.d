#!/usr/bin/env dmd

/*
  Purpose : Plot bar from STDIN input
  Author  : Ky-Anh Huynh
  Date    : 2017 Sep 5th
  License : MIT
  Idea    : https://github.com/lebinh/goplot
  Contract:
    Input :   <name>  <number>
    Output:   <bar(s)>
*/

import std.stdio;
import std.format;
import std.string;
import core.stdc.stdlib;
import std.math;
import std.algorithm;
import std.conv;
import std.exception;

void main(string[] args) {
  uint min_percent = 0;

  if (args.length >= 2 && args[1] == "-m") {
    if (args.length == 2) {
      stderr.writeln(":: Error: Missing number argument for -m option.");
      exit(1);
    }
    try {
      args[2].formattedRead!"%d"(min_percent);
    }
    catch (Exception exc) {
      stderr.writeln(":: Unable to get minium percent with -m option.");
      exit(1);
    }
  }

  if (min_percent >= 100) {
    stderr.writeln(":: Minimum percent must be less than 100.");
    exit(1);
  }

  double[string] plotdata;

  foreach (string line; lines(stdin)) {
    auto line_st = line.strip();
    try {
      string key;
      double value;
      if (line_st.length) {
        line_st.formattedRead!"%s %f"(key, value);
        if (key.length && !isNaN(value) && value >= 0) {
          plotdata[key] = value + plotdata.get(key, 0);
        }
        else {
          // FIXME: can't use line_st instead of line.strip()
          stderr.writefln(":: Line discarded: %s", line.strip());
        }
      }
    }
    catch (Exception exc) {
      // FIXME: can't use line_st instead of line.strip()
      stderr.writefln(":: Line ignored: %s", line.strip());
    }
  }

  auto sum_input = plotdata.byValue.sum();

  if (plotdata.length < 1 || sum_input == 0) {
    stderr.writefln(":: Plot data (size %d) is empty or all entries are equal to 0.", plotdata.length);
    exit(0);
  }

  auto max_key_width = plotdata.byKey.map!(s => s.length)().reduce!(max);

  foreach (key, value; plotdata) {
    auto bar = roundTo!uint(value / sum_input * 100);
    if (bar < min_percent) {
      continue;
    }
    auto bar_st = leftJustify("", bar, '=');
    auto key_st = rightJustify(key, max_key_width, ' ');
    writefln("%s : %2d %% %s (%s)", key_st, bar, bar_st, roundTo!size_t(value));
  }
}
