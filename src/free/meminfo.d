/*
  Purpose : Parse /proc/meminfo
  Author  : Ky-Anh Huynh
  Date    : 2017 Sep 10th
  Licens  : MIT
*/

module dusybox.meminfo;

import std.stdio;
import std.format;

/*
  $ cat /proc/meminfo
  MemTotal:       16337684 kB
  MemFree:         2612196 kB
  MemAvailable:   12543580 kB
  Buffers:         1127916 kB
  Cached:          7467756 kB
  ...
*/
size_t[string] meminfo(in string[] lines) {
  size_t[string] results;

  foreach(string line; lines) {
    string key;
    size_t value;
    auto line_st = line;
    try {
      line_st.formattedRead!"%s: %s"(key, value);
      results[key] = value;
    }
    catch (Exception exc) {
      debug(2) stderr.write("meminfo: Unable to parse (key, value) from line '%s'", line);
    }
  }

  if ("Cached" !in results
    || "MemAvailable" !in results
    || "MemTotal" !in results
    || "MemFree" !in results
    || "Buffers" !in results
    || "Shmem" !in results
    || "SReclaimable" !in results) {

    stderr.writeln("meminfo: Missing some memory information.");
    return results;
  }

  results["PageCached"] = results["Cached"];
  results["Cached"] = results["PageCached"] + results["SReclaimable"];

  /*
  See https://gitlab.com/procps-ng/procps/blob/master/proc/sysinfo.c#L792

  Quoted:
    if kb_main_available is greater than kb_main_total or our calculation of
    mem_used overflows, that's symptomatic of running within a lxc container
    where such values will be dramatically distorted over those of the host.
  */
  if (results["MemAvailable"] > results["MemTotal"]) {
    results["MemAvailable"] = results["MemFree"];
  }
  auto mem_used = results["MemTotal"] - results["MemFree"];
  if (mem_used >= results["Buffers"] + results["Cached"]) {
    mem_used -= results["Buffers"] + results["Cached"];
  }

  results["MemUsed"] = mem_used;

  return results;
}

size_t[string] meminfo(in string filename = "/proc/meminfo") {
  string[] lines;

  foreach(string line; std.stdio.lines(filename.File("r"))) {
    lines ~= line;
  }
  return meminfo(lines);
}

unittest {
  string[] empty_arr;
  size_t[string] empty_result;

  assert(empty_result == meminfo(empty_arr));

  const string[] lines = [
    "MemTotal:       10000 kB\n",
    "MemFree:         1000 kB\n"];

  auto results = meminfo(lines);

  assert(results["MemTotal"] == 10000, "Unable to read MemTotal.");
  assert(results["MemFree"]  == 1000, "Unable to read MemFree.");

  results = meminfo();
  assert(results["Active"] > 0);
}
