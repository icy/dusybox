/*
  Purpose : Parse user input
  Author  : Ky-Anh Huynh
  Date    : 2017 Sep 19th
  License : MIT
*/

module plotbar.utils;

void parse_argument(string[] args, out bool reversed, out uint min_percent)
in {
  assert(args.length > 0, "Input args must contain a program name.");
}
out {
  assert(min_percent < 100, "Mininum percent must less than 100.");
}
do {
  import std.conv;
  import std.exception;
  import std.getopt;
  import std.stdio;
  import core.stdc.stdlib: exit;
  import std.format;

  try {
    auto helpInformation = getopt(args,
      "m",  "Minimum percent to display (0 -> 99)", &min_percent,
      "reversed|r", "Read the value from the start of line", &reversed,
      std.getopt.config.stopOnFirstNonOption
    );

    if (helpInformation.helpWanted) {
      defaultGetoptPrinter("dzplotbar - Draw 2-d barchart from key-value STDIN.

The program parses each line from STDIN, and expects key-value format.
The key can contain spaces/tabs, and the value is expected to read from
the last position of the line. If value is expected to read from the
very start of the line, use option `--reversed`. All lines that don't
follow key-value format will be ignored/discarded.

During the parsing process, split() function is used to build up key name
For this reason, two keys `foo bar` or `foo    bar` are identical.

Sample key-value input:

  foo       1
  foo bar   2.6
  foo  bar  2.7

", helpInformation.options);
      exit(0);
    }

  }
  catch (GetOptException exc) {
    // Stop processing at the first unknown argument
  }
  catch (Exception exc) {
    throw new Exception(format(":: Error: %s", exc.msg));
  }

  if (min_percent >= 100) {
    throw new Exception(":: Error: min percent must be less than 100.");
  }
}

unittest {
  import std.exception;

  uint min_percent = 0;
  bool reversed = false;
  parse_argument(["foo"], reversed, min_percent);
  assert(min_percent == 0);
  assertThrown(parse_argument(["foo", "-m", "-1"], reversed, min_percent), "Negative percent should throw an exception.");
  assertThrown(parse_argument(["foo", "-m", "100"], reversed, min_percent), "Percent >= 100 should raise an error.");

  parse_argument(["foo", "-n", "10", "-m", "10"], reversed, min_percent);
  assert(min_percent == 10, "min percent is parsed");

  parse_argument(["foo", "-m", "10", "-m", "11", "-n", "10"], reversed, min_percent);
  assert(min_percent == 11, "min percent is 11");
}

void read_key_value(ref double[string] plotdata, in bool reversed, in string line) {
  import std.string : strip, split;
  import std.array: join;
  import std.math;
  import std.stdio;
  import std.format: formattedRead;

  auto line_st = line.strip();
  auto line_orig = line_st;
  try {
    string key;
    double value;
    auto line_arr = line_st.split();
    if (line_arr.length >= 2) {
      if (reversed) {
        line_arr[0].formattedRead!"%f"(value);
        key = line_arr[1..$].join(' ');
      } else {
        line_arr[$-1].formattedRead!"%f"(value);
        key = line_arr[0..$-1].join(' ');
      }
      if (key.length && !isNaN(value) && value >= 0) {
        plotdata[key] = value + plotdata.get(key, 0);
      }
      else {
        debug(2) stderr.writefln(":: Line discarded: %s", line_orig);
      }
    }
  }
  catch (Exception exc) {
    debug(2) stderr.writefln(":: Line ignored: %s", line_orig);
  }
}

unittest {
  double[string] result;

  result.read_key_value(false, "");
  assert(result is null);

  result.read_key_value(false, "a             1");
  result.read_key_value(false, "at1           \t1");
  result.read_key_value(false, "at2 t         \t1");
  result.read_key_value(false, "b             x");
  result.read_key_value(false, "ax            1.2"); // Space doesn't matter
  result.read_key_value(false, "ay  \t        1"); // Space doesn't matter
  result.read_key_value(false, "c d           1"); // Value is on the last position
  result.read_key_value(true,  "100           reversed  direction");

  assert(result.length > 0, "Result should not be empty.");
  assert("b" !in result, "Invalid value should not be included.");
  assert("c d" in result, "Unable to parse key with space in name (Expected key: 'c d').");
  assert("at1" in result, "Tab delimiter is working well.");
  assert("at2 t" in result, "Tab delimiter is working well.");
  assert("reversed direction" in result, "Unable to parse input in reversed direction.");
  assert(result["reversed direction"] == 100, "Reversed direction is not working.");
  assert(result["c d"] == 1, "Can parse key = 'c d' from space delimiter input.");
  assert(result["a"] == 1, "Can parse key = a from space delimiter input.");
  assert(result["ax"] == 1.2, "Can parse key = ax from space delimiter input.");
  assert(result["ay"] == 1, "Can parse key = ay from space delimiter input.");
}
