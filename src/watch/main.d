/*
  Purpose : Provide similar function to `watch`
  Author  : Ky-Anh Huynh
  Date    : 2018 Sep 04th
  License : MIT
  FIXME   : NCException occurs for `ps xauw` command (`ps x` is fine)
*/

import deimos.ncurses;
import std.stdio;
import core.thread;
import std.process;
import std.format;
import core.stdc.stdlib;
import std.datetime;
import std.string: toStringz;
import core.stdc.locale; // setlocale()

void main(string[] args) {
  auto cmd_start = 1;
  auto max_iteration = size_t.max;

  if (args.length >= 2 && args[cmd_start] == "-n") {
    cmd_start += 1;
    if (cmd_start >= args.length) {
      stderr.writeln(":: Error: Missing number for -n argument.");
      exit(1);
    }
    else {
      try {
        args[cmd_start].formattedRead!"%d"(max_iteration);
      }
      catch (Exception exc) {
        max_iteration = 0;
      }

      if (max_iteration <= 0) {
        stderr.writeln(":: Error: Max iteration is too small or invalid.");
        exit(1);
      }
      cmd_start += 1;
    }
  }

  if (cmd_start >= args.length) {
    stderr.writeln(":: Error: Please specify command to watch.");
    exit(1);
  }

  // https://github.com/D-Programming-Deimos/ncurses/blob/master/examples/hellounicode/source/helloUnicode.d
  setlocale(LC_CTYPE,"");

  initscr();

  // https://github.com/D-Programming-Deimos/ncurses/blob/master/examples/key_code/source/key_code.d
  cbreak();
  timeout(1);
  noecho();
  // keypad(stdscr, false);

  scope(exit)     endwin();
  scope(failure)  endwin();

  auto cnt = 0;
  int chr = 65;

  while (true) {
    clear();
    mvprintw(0, 0, "%s", format(":: No %d/%d, Cmd %s", ++cnt, max_iteration, args[cmd_start..$]).toStringz);
    try {
      auto cmd_exec = (cmd_start == args.length - 1) ? executeShell(args[cmd_start]) : execute(args[cmd_start..$]);
      mvprintw(1, 0, "%s", cmd_exec.output.toStringz);
    }
    catch (Exception exc) {
      clear();
      mvprintw(0, 0, "%s", format(":: No %d/%d, Cmd %s", cnt, max_iteration, args[cmd_start..$]).toStringz);
      mvprintw(1, 0, "%s", "NCException occurred.".toStringz);
    }
    finally {
      move(0, 0);
      refresh();
      doupdate();
      chr = getch();
      Thread.sleep(1000.msecs);
    }
    if (cnt == max_iteration) {
      endwin();
      stderr.writefln(":: Reached maximum number of interation (%d) at %s.", max_iteration, Clock.currTime());
      break;
    }
    else if (chr == 'q' || chr == 'Q') {
      endwin();
      stderr.writefln(":: Use requested to exit. Iteration %d at %s.", cnt, Clock.currTime());
      break;
    }
  }
}
