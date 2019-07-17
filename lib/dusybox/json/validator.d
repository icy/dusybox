/*
  author      : ky-anh huynh
  license     : mit
  date        : 2019-07-17
  purpose     : a simple json validator
  inspired by : https://github.com/rycus86/webhook-proxy/blob/a8919cc82173b8e7a4cb0a2ba8a34a14996e159c/src/endpoints.py#L141
*/

module dusybox.json.validator;
import std.json;

debug import std.stdio;

auto json_value_as_string(JSONValue value) {
  if (value.type == JSONType.string) {
    return value.str;
  }
  else {
    import std.format;
    return "%s".format(value);
  }
}

bool validate_a_path(string path, JSONValue value, JSONValue rule) {
  if (value.type == JSONType.object && rule.type == JSONType.object) {
    if (! validate(rule, value, path)) {
      debug writefln(":: validate_a_path '%s' with a dict value, using rule %s [FAIL]", path, rule);
      return false;
    }
  }
  else if (rule.type != JSONType.string) {
    debug writefln(":: validate_a_path '%s' with value %s, using rule %s (which is not a string) must return false", path, value, rule);
    return false;
  }
  else {
    import std.regex, std.format;
    if (! value.json_value_as_string.matchFirst(regex(rule.str, "m"))) {
      debug writefln(":: validate_a_path '%s' with value %s, using rule %s (regexp) [FAIL]", path, value, rule);
      return false;
    }
    else {
      debug(3) writefln(":: validate_a_path '%s' with value %s, using rule %s (regexp) [PASS]", path, value, rule);
    }
  }

  return true;
}

bool validate(JSONValue checks, JSONValue payload, string path = "root") {
  bool status = true;

  int walk_through_check(string key, ref JSONValue rule) {
    int loopflag = 0;

    JSONValue value;
    if (key in payload) {
      value = payload[key];
    }

    if (value.isNull) {
      debug writefln(":: validate(%s) key: '%s' not found in payload. Return True", path, key);
      status = true;
    }
    else if (value.type == JSONType.array) {
      debug writefln(":: validate(%s) payload value is an array %s", path, value);
      foreach (ulong idx, item; value) {
        if (! validate_a_path(path, item, rule)) {
          status = false;
          return 0;
        }
      }
    }
    else {
      import std.format;
      auto new_path = "%s.%s".format(path, key);
      if (! validate_a_path(new_path, value, rule)) {
        status = false;
        return 0;
      }
    }

    return loopflag;
  }

  checks.opApply(&walk_through_check);
  debug writefln(":: validate(%s) result: %s", path, status);
  return status;
}

unittest {
  auto wrap(string st) {
    ulong max = 32;
    import std.regex;
    auto st2 = st.replaceAll(regex(r"[\r\n]+"), "").replaceAll(regex(r" {2,}"), "");
    if (st2.length < max) {
      max = st2.length;
    }
    return st2[00..max];
  }

  auto mytest(string st1, string st2) {
    debug writefln("<< test %s vs input %s", wrap(st1), wrap(st2));
    auto c = std.json.parseJSON(st1);
    auto p = std.json.parseJSON(st2);
    return validate(c, p);
  }


  assert(mytest(`{"foo": ".+"}`, `{"foo": true}`));
  assert(mytest(`{"foo": ".+"}`, `{"foo": false}`));
  assert(mytest(`{"foo": ".+"}`, `{"foo": 0}`));
  assert(mytest(`{"foo": ".+"}`, `{"foo": [0,1,"bar"]}`));
  assert(!mytest(`{"foo": "[0-9]+"}`, `{"foo": [0,1,"bar"]}`));
  assert(mytest(`{"foo": "[0-9]+"}`, `{"foo": [0,1,"2bar"]}`));
  assert(!mytest(`{"foo": "[0-9]{2}"}`, `{"foo": [0,1,"2bar"]}`));

  auto c = `
    {
      "commit": {
        "id": "^[0-9a-f]{40}",
        "message": ".+",
        "author": {
          "name": ".+"
        }
      },
      "test_array1": ".+",
      "test_array2": ".+"
    }
    `;

  auto p =
    `
      {
        "commit": {
          "id": "2bbb1c00f0700263546314747a3b47076c0fba7b",
          "author": {
            "email": "test@example.net",
            "name": "Some User",
            "foo": {
              "bar1": {"test": "foo"},
              "bar2": {"test": "bar"}
            }
          },
          "message": "PID-0000: Minor updates",
          "url": "https://git.lauxanh.us/tools/foo/commit/2bbb1c00f0700263546314747a3b47076c0fba7b",
          "timestamp": "2019-06-20T15:56:17Z"
        },
        "test_array1": [
          "one",
          "two",
          "three"
        ],
        "test_array2": [
          0,
          1,
          "one",
          "two",
          "three"
        ]
      }
    `;

  assert(mytest(c,p));
}
