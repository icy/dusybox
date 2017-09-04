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

void main(string[] args) {
  Curses.Config cfg = {
    disableEcho: true,
    nodelay: true
  };

  auto curses = new Curses(cfg);
  auto scr = curses.stdscr;
  auto cnt = 0;

  while (true) {
    scr.addstr(0, 0, format(":: No %d, Cmd %s", ++cnt, args[1..$]));
    try {
      auto cmd_exec = execute(args[1..$]);
      scr.addnstr(1, 0, cmd_exec.output, int.max);
    }
    catch (nice.curses.NCException exc) {
      scr.clear();
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
  }
}
