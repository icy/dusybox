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
import std.conv;
import std.exception;
import std.getopt;
import dusybox.plot;

void main(string[] args) {
  uint min_percent = 0;

  try {
    auto helpInformation = getopt(args,
      "m",  "Minimum percent to display (0 -> 99)", &min_percent,
      std.getopt.config.stopOnFirstNonOption
    );

    if (helpInformation.helpWanted) {
      defaultGetoptPrinter("dzplotbar - Draw 2-d barchart.", helpInformation.options);
      exit(0);
    }

  }
  catch (GetOptException exc) {
    // Stop processing at the first unknown argument
  }
  catch (Exception exc) {
    stderr.writefln(":: Error: %s", exc.msg);
    exit(1);
  }

  if (min_percent >= 100) {
    stderr.writeln(":: Minimum percent must be less than 100.");
    exit(1);
  }

  double[string] plotdata;

  foreach (string line; lines(stdin)) {
    auto line_st = line.strip();
    auto line_st2 = line_st;
    try {
      string key;
      double value;
      if (line_st.length) {
        line_st.formattedRead!"%s %f"(key, value);
        if (key.length && !isNaN(value) && value >= 0) {
          plotdata[key] = value + plotdata.get(key, 0);
        }
        else {
          stderr.writefln(":: Line discarded: %s", line_st2);
        }
      }
    }
    catch (Exception exc) {
      stderr.writefln(":: Line ignored: %s", line_st2);
    }
  }

  plotdata.tobars(min_percent).format!"%-(%s\n%)".writeln;
}
