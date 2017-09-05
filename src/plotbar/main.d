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

void main() {
  double[string] plotdata;

  string key;
  double value;

  foreach (string line; lines(stdin)) {
    try {
      auto line_st = line.strip();
      if (line_st.length) {
        line_st.formattedRead!"%s %f"(key, value);
        if (key.length && !isNaN(value) && value >= 0) {
          plotdata[key] = value;
        }
        else {
          stderr.writeln(format(":: Line discarded: %s", line_st));
        }
      }
    }
    catch (Exception exc) {
      stderr.writeln(format(":: Line ignored: %s", line.strip()));
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
    auto bar_st = leftJustify("", bar, '=');
    auto key_st = rightJustify(key, max_key_width, ' ');
    writefln("%s : %2d %% %s", key_st, bar, bar_st);
  }
}
