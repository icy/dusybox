/*
  Purpose : A simple and stupid jq util
  Author  : Ky-Anh Huynh
  License : MIT
  Date    : 2017 Sep 05th
*/

import std.stdio;
import std.json;
import std.format;
/* alias KeepTerminator = std.typecons.Flag!"keepTerminator".Flag; */
import std.typecons;

public import dusybox.json;

void main(string[] args) {
  foreach(char[] line; stdin.byLine(No.keepTerminator)) {
    try {
      line.parseJSON.json_resolve(args[1..$]).format!"%-(%s%| %)".writeln;
    }
    catch (Exception exc) {
      stderr.writef(":: Exception occured. Line skipped %s\n", line);
    }
  }
}
