/*
  Purpose : Parse user input
  Author  : Ky-Anh Huynh
  Date    : 2017 Sep 19th
  License : MIT
*/

module plotbar.utils;

void parse_argument(string[] args, out uint min_percent)
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
    throw new Exception(format(":: Error: %s", exc.msg));
  }

  if (min_percent >= 100) {
    throw new Exception(":: Error: min percent must be less than 100.");
  }
}

unittest {
  import std.exception;

  uint min_percent = 0;
  parse_argument(["foo"], min_percent);
  assert(min_percent == 0);
  assertThrown(parse_argument(["foo", "-m", "-1"], min_percent), "Negative percent should throw an exception.");
  assertThrown(parse_argument(["foo", "-m", "100"], min_percent), "Percent >= 100 should raise an error.");

  parse_argument(["foo", "-n", "10", "-m", "10"], min_percent);
  assert(min_percent == 10, "min percent is parsed");

  parse_argument(["foo", "-m", "10", "-m", "11", "-n", "10"], min_percent);
  assert(min_percent == 11, "min percent is 11");
}

void read_key_value(ref double[string] plotdata, in string line) {
  import std.string : strip, split;
  import std.array: join;
  import std.math;
  import std.stdio;
  import std.format: formattedRead;

  auto line_st = line.strip();
  auto line_st2 = line_st;
  try {
    string key;
    double value;
    if (line_st.length) {
      auto line_st_ = line_st.split.join(' ');
      line_st_.formattedRead!"%s %f"(key, value);
      if (key.length && !isNaN(value) && value >= 0) {
        plotdata[key] = value + plotdata.get(key, 0);
      }
      else {
        debug(2) stderr.writefln(":: Line discarded: %s", line_st2);
      }
    }
  }
  catch (Exception exc) {
    debug(2) stderr.writefln(":: Line ignored: %s", line_st2);
  }
}

unittest {
  double[string] result;

  result.read_key_value("");
  assert(result is null);

  result.read_key_value("a 1");
  assert(result.length && result["a"] == 1, "Can parse key = a from space delimiter input.");
  assert("b" !in result, "Invalid value should not be included.");

  result.read_key_value("c\t1");
  assert(result.length && result["c"] == 1, "Can parse key = c from tab delimiter input.");
}
