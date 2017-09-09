/*
  Purpose : A D-implementation of http://rosettacode.org/wiki/Terminal_control/Preserve_screen#C
  Author  : Ky-Anh Huynh
  Date    : 2017 Sep 09th
  License : MIT
*/

import std.stdio;
import std.format;
import core.thread;

void main() {
  write("\033[?1049h\033[H");
  writeln("This is the alternate buffer. Going to switch back in 4 seconds.");
  stdout.flush();
  Thread.sleep(4000.msecs);
  write("\033[?1049l");
}
