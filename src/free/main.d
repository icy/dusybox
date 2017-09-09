#!/usr/bin/env rdmd

/*
  Purpose : Collect memory information (similar to `free`...)
  Author  : Ky-Anh Huynh
  Date    : 2017 Sep 04
  License : MIT
  FIXME   : This program may not wokr with your Linux Kernel :)
*/

import std.stdio;
import std.format;

void main() {
  /*
  Sample output from `cat /proc/meminfo` command

    $ cat /proc/meminfo
    MemTotal:       16337684 kB
    MemFree:         2612196 kB
    MemAvailable:   12543580 kB
    Buffers:         1127916 kB
    Cached:          7467756 kB
    SwapCached:            0 kB
    Active:          4791128 kB
    Inactive:        7063908 kB
    Active(anon):    2615680 kB
    Inactive(anon):   614036 kB
    Active(file):    2175448 kB
    Inactive(file):  6449872 kB
    Unevictable:          20 kB
    Mlocked:              20 kB
    SwapTotal:             0 kB
    SwapFree:              0 kB
    Dirty:              5804 kB
    Writeback:             0 kB
    AnonPages:       2869652 kB
    Mapped:           819936 kB
    Shmem:            630284 kB
    Slab:            1723608 kB
    SReclaimable:    1647404 kB
    SUnreclaim:        76204 kB
    KernelStack:        8912 kB
    PageTables:        35688 kB
    NFS_Unstable:          0 kB
    Bounce:                0 kB
    WritebackTmp:          0 kB
    CommitLimit:     8168840 kB
    Committed_AS:    7582948 kB
    VmallocTotal:   34359738367 kB
    VmallocUsed:           0 kB
    VmallocChunk:          0 kB
    HardwareCorrupted:     0 kB
    AnonHugePages:    817152 kB
    ShmemHugePages:        0 kB
    ShmemPmdMapped:        0 kB
    HugePages_Total:       0
    HugePages_Free:        0
    HugePages_Rsvd:        0
    HugePages_Surp:        0
    Hugepagesize:       2048 kB
    DirectMap4k:      365360 kB
    DirectMap2M:    12118016 kB
    DirectMap1G:     4194304 kB
  */
  enum MemInfo {
    MemTotal,
    MemFree,
    MemAvailable,
    Buffers,
    Cached,
    SwapCached,
    Active,
    InActive,
    ActiveAnon,
    InActiveAnon,
    ActiveFile,
    InActiveFile,
    Unevictable,
    Mlocked,
    SwapTotal,
    SwapFree,
    Dirty,
    Writeback,
    AnonPages,
    Mapped,
    Shmem,
    Slab,
    SReclaimable
  }

  auto lineno = MemInfo.min;
  auto fh_proc_meminfo = File("/proc/meminfo", "r");

  size_t mem_total;
  size_t mem_free;
  size_t mem_available;
  size_t mem_page_cached;
  size_t mem_buffers;
  size_t mem_shared;
  size_t mem_slab_reclaimable;
  size_t mem_cached; /* mem_page_cached + mem_slab_reclaimable */

  size_t mem_used;

  foreach (string line; lines(fh_proc_meminfo)) {
    switch (lineno) {
    case MemInfo.MemTotal:
      line.formattedRead!"MemTotal: %s"(mem_total);
      break;
    case MemInfo.MemFree:
      line.formattedRead!"MemFree: %s"(mem_free);
      break;
    case MemInfo.MemAvailable:
      line.formattedRead!"MemAvailable: %s"(mem_available);
      break;
    case MemInfo.Cached:
      line.formattedRead!"Cached: %s"(mem_page_cached);
      break;
    case MemInfo.Buffers:
      line.formattedRead!"Buffers: %s"(mem_buffers);
      break;
    case MemInfo.Shmem:
      line.formattedRead!"Shmem: %s"(mem_shared);
      break;
    case MemInfo.SReclaimable:
      line.formattedRead!"SReclaimable: %s"(mem_slab_reclaimable);
      break;
    default:
      break;
    }

    if (++lineno > MemInfo.max) {
      break;
    }
  }

  mem_cached = mem_page_cached + mem_slab_reclaimable;
  /*
  See https://gitlab.com/procps-ng/procps/blob/master/proc/sysinfo.c#L792

  Quoted:
    if kb_main_available is greater than kb_main_total or our calculation of
    mem_used overflows, that's symptomatic of running within a lxc container
    where such values will be dramatically distorted over those of the host.
  */
  if (mem_available > mem_total) {
    mem_available = mem_free;
  }
  mem_used = mem_total - mem_free;
  if (mem_used >= mem_buffers + mem_cached) {
    mem_used -= mem_buffers + mem_cached;
  }

  /*
  Sample output from `free -m` command.
  See also https://gitlab.com/procps-ng/procps/blob/master/free.c#L363

    $ free
                  total        used        free      shared  buff/cache   available
    Mem:       16337684     3283552     2857804      600292    10196328    12603728
    Swap:             0           0           0
  */
  writeln("              total        used        free      shared  buff/cache   available");
  writefln("%-7s %11s %11s %11s %11s %11s %11s",
    "Mem:",
    mem_total,
    mem_used,
    mem_free,
    mem_shared,
    mem_buffers + mem_cached,
    mem_available);

  stdout.flush();
}
