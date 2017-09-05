#!/usr/bin/env dmd

/*
  Purpose : A simple and stupid jq util
  Author  : Ky-Anh Huynh
  License : MIT
  Date    : 2017 Sep 05th
*/

import std.stdio;
import std.json;
import std.conv;
import std.algorithm;

/* alias KeepTerminator = std.typecons.Flag!"keepTerminator".Flag; */
import std.typecons;

string jsonresolve(JSONValue j, ref string symbol) {
  auto symbol_n = symbol[0..$];
  if (symbol.length > 0 && symbol[0] == '.') {
    symbol_n = symbol[1..$];
    return (symbol_n in j)
      ? (j[symbol_n].type() == JSON_TYPE.STRING
          ? j[symbol_n].str
          : to!string(j[symbol_n]))
      : symbol;
  }
  else {
    return symbol;
  }
}

void main(string[] args) {
  /* The header

  if (args.length > 1) {
    writefln("%-(%s%|\t%)", args[1..$]);
  }
  */

  foreach(char[] line; stdin.byLine(No.keepTerminator)) {
    try {
      auto jsond = parseJSON(line);
      if (args.length > 1) {
        auto result = args[1..$].map!(a => jsonresolve(jsond, a));
        writefln("%-(%s%| %)", result);
      }
      else {
        writeln(jsond.toString);
      }
    }
    catch (Exception exc) {
      stderr.writef(":: Exception occured. Line skipped %s\n", line);
    }
  }
}
