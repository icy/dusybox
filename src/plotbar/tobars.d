/*
  Purpose : Common function to deal with bar chats
  Author  : Ky-Anh Huynh
  License : MIT
  Date    : 2017-Sep-09th
*/

module dusybox.plot;

import std.algorithm;
import std.array: array;
import std.conv;
import std.math;
import std.stdio;
import std.format;
import std.string;

struct Bar {
  string  key;
  uint    len;
  double  value;

  // FIXME: This should be a private value...
  // FIXME: Has ability to reset max_key_width for next iteraction
  static
  ulong   max_key_width = 0;

  this(in string key, in double len, in double value) {
    this.key = key;
    this.len = roundTo!uint(len);
    this.value = value;
    if (key.length > this.max_key_width) {
      this.max_key_width = key.length;
    }
    debug(2) stderr.writefln(format!"(debug) New Bar: key = %s (w = %d), len = %s, value = %s"(this.key, this.max_key_width, this.len, this.value));
  }

  string toString() const {
    auto bar_st = leftJustify("", len, '=');
    auto key_st = rightJustify(key, max_key_width, ' ');
    return format!"%s : %3d %% %s (%s)"(key_st, len, bar_st, roundTo!size_t(value));
  }

  static
  void reset() {
    max_key_width = 0;
  }

  bool opEquals(in Bar rhs) const {
    return (key == rhs.key) && (len == rhs.len);
  }
}

Bar[] tobars(in double[string] plotdata, in uint min_percent = 0) {
  Bar[] results;

  auto sum_input = plotdata.byValue.sum();

  if (plotdata.length < 1 || sum_input == 0) {
    debug stderr.writefln(":: Plot data (size %d) is empty or all entries are equal to 0.", plotdata.length);
    return results;
  }

  foreach (key, value; plotdata) {
    auto len = value / sum_input * 100;
    // FIXME: How to avoid to create new object Bar if len < min_percent?
    if (len < min_percent) {
      continue;
    }
    results ~= Bar(key, len, value);
  }

  return results;
}

unittest {
  import std.array: array;

  double[string] empty_arr;
  Bar[] empty_result;

  assert(empty_arr.tobars               == empty_result, "Empty input should return empty array of Bar.");
  assert(["foo1": 0, "bar1": 0].tobars  == empty_result, "Zero sum should return empty array of Bar.");

  assert(["foo": 1].tobars    == [Bar("foo", 100, 1)], "Single bar entry with integer value.");
  assert(["foo": 1.1].tobars  == [Bar("foo", 100, 1)], "Single bar entry with floating input value.");

  auto results = ["foo1": 1, "bar1": 1].tobars;
  results.format!"%-(%s\n%)".writeln;
  assert(results[0].len == results[1].len);

  results = ["foo2": 1, "bar2": 1.2].tobars;
  results.format!"%-(%s\n%)".writeln;
  assert(results[0].len == 45 || results[0].len == 55);
  assert(results[1].len == 45 || results[1].len == 55);

  assert(Bar.max_key_width > 0);
  Bar.reset();
  assert(Bar.max_key_width == 0);
}
