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

import dusybox.plot;
public import plotbar.utils;

void main(string[] args) {
  uint min_percent = 0;
  args.parse_argument(min_percent);

  double[string] plotdata;
  foreach (string line; lines(stdin)) {
    plotdata.read_key_value(line);
  }

  plotdata.tobars(min_percent).format!"%-(%s\n%)".writeln;
}
