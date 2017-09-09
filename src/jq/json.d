/*
  Purpose : Simple JSON query tool
  Author  : Ky-Anh Huynh
  License : MIT
  Date    : 2017 Sep 09th
*/

module dusybox.json;

import std.json;
import std.conv;
import std.algorithm;
import std.array: array;

string json_resolve(in JSONValue j, in string symbol) {
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

string[] json_resolve(in JSONValue j, in string[] symbols) {
  string[] results;

  if (symbols.length > 0) {
    results = symbols.map!(a => j.json_resolve(a)).array;
  }
  else {
    results ~= j.toString;
  }

  return results;
}

unittest {
  auto jsond = parseJSON("{\"a\": 1, \"b\": \"x\", \"c\": {\"ca\": 0}}");

  assert(json_resolve(jsond, ".a") == "1",  "Integer value should be resolved to a string.");
  assert(json_resolve(jsond, ".x") == ".x", "Unknown key should be resolved to key per-se.");
  assert(json_resolve(jsond, ".c") == "{\"ca\":0}", "Object should be resolved to string version of them.");

  assert(json_resolve(jsond, [".a", ".x"]) == ["1", ".x"]);
  assert(json_resolve(jsond, [".a", " ", "1"]) == ["1", " ", "1"]);

  string[] empty_arr;
  assert(json_resolve(jsond, empty_arr) == [jsond.toString]);
}
