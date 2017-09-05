#!/usr/bin/env dmd

/*
  Purpose : Provide similar function to `watch`
  Author  : Ky-Anh Huynh
  Date    : 2018 Sep 04th
  License : MIT
  FIXME   : NCException occurs for `ps xauw` command (`ps x` is fine)
*/

import nice.curses;
import std.stdio;
import core.thread;
import std.process;
import std.format;
import core.stdc.stdlib;
import std.datetime;

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

  Curses.Config cfg = {
    disableEcho: true,
    nodelay: true
  };

  auto curses = new Curses(cfg);
  auto scr = curses.stdscr;
  auto cnt = 0;

  while (true) {
    scr.clear();
    scr.addstr(0, 0, format(":: No %d/%d, Cmd %s", ++cnt, max_iteration, args[cmd_start..$]));
    try {
      auto cmd_exec = (cmd_start == args.length - 1) ? executeShell(args[cmd_start]) : execute(args[cmd_start..$]);
      scr.addnstr(1, 0, cmd_exec.output, int.max);
    }
    catch (nice.curses.NCException exc) {
      scr.clear();
      scr.addstr(0, 0, format(":: No %d/%d, Cmd %s", cnt, max_iteration, args[cmd_start..$]));
      scr.addstr(1, 0, "NCException occurred.");
    }
    catch (Exception exc){
      scr.addstr(1, 0, exc.msg);
    }
    finally {
      scr.move(0, 0);
      scr.refresh();
      curses.update();
      Thread.sleep(1000.msecs);
    }
    if (cnt == max_iteration) {
      destroy(curses);
      stderr.writefln(":: Reached maximum number of interation (%d) at %s.", max_iteration, Clock.currTime());
      break;
    }
  }
}
