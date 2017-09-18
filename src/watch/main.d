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
import std.getopt;
import std.conv;

void main(string[] args) {
  auto max_iteration = size_t.max;

  try {
    auto helpInformation = getopt(args,
      std.getopt.config.stopOnFirstNonOption,
      "n", "Maximum number of executions. Default: Unlimited.", &max_iteration);

    if (helpInformation.helpWanted) {
      defaultGetoptPrinter("dzwatch - Execute command and watch their output every one second.", helpInformation.options);
      exit(0);
    }

  }
  catch (ConvException exc) {
    stderr.writefln(":: Error: %s", exc.msg);
    exit(1);
  }
  catch (GetOptException exc) {
    // Stop processing at the first unknown argument
  }

  if (max_iteration < 1) {
    stderr.writefln(":: Error: Invalid argument: -n %s", max_iteration);
    exit(1);
  }
  if (args.length < 2) {
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
    mvprintw(0, 0, "%s", format(":: No %d/%d, Cmd %s", ++cnt, max_iteration, args[1..$]).toStringz);
    try {
      auto cmd_exec = (1 == args.length - 1) ? executeShell(args[1]) : execute(args[1..$]);
      mvprintw(1, 0, "%s", cmd_exec.output.toStringz);
    }
    catch (Exception exc) {
      clear();
      mvprintw(0, 0, "%s", format(":: No %d/%d, Cmd %s", cnt, max_iteration, args[1..$]).toStringz);
      mvprintw(1, 0, "%s", "Exception occurred.".toStringz);
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
