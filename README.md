## Description

Simple implementations of System Ultilities in Dlang.

The primary purpose is to understand `Dlang`
and to learn system programming.

## TOC

* [free](#free)
* [watch](#watch)
* [plotbar](#plotbar)

## free

Print information about system memory.

It's similar to the `free` command on your `Linux` system.

The original `free` tool is written in `C` and it uses a `bsearch`
routine to look up various fields in `/proc/meminfo`. We don't use
the same strategy in this version: Instead, we use a static `enum` that defines
an ordered list of items to fetch. This order will not be portable
and that's the reason this tool may not work with your kernel.

This tool is tested on `Linux 4.12.8-2`.

### TODO

- [ ] Support different Linux versions
- [ ] Print human-readable memory size

### Example

```
$ dub run dusybox:free
              total        used        free      shared  buff/cache   available
Mem:       16337684     4161480     1770368      726864    10405836    11925640
```

## watch

Execute a shell command and print its output to the standard output device
every one second. This is similar to the popular `watch` command.

This tool uses [nice-curses](https://github.com/mpevnev/nice-curses) library.
It can handle some fancy output, but it seems it can't handle big output
and/or any special characters.

### TODO

- [x] Print time information of the last interaction
- [x] Print basic information about input command and iterator number.
- [x] Wait 1 second after every execution. No more `--interval 1` :)
- [x] Specify maxium number of executions with `-n <number>`
- [ ] Fix problem with complex command `ps xauw`
- [ ] Exit if output matches some regular expression
- [ ] Exit if user presses `q` or `Q`
- [x] Tool doesn't work with pipe commands, e.g, `ps x | grep foo`:
      it reports `command not found` error. As a work-around you can
      use `bash -c "ps x | grep ff"` instead.

### Examples

```
$ dub run dusybox:watch -- free -m
$ dub run dusybox:watch -- ps x

$ dub run dusybox:watch -- -n 10 'ps xwa | grep "f[i]r"'
:: No 4/10, Cmd ["ps xwa | grep \"f[i]r\""]
15774 ?        SNsl   3:01 /usr/lib/firefox/firefox
15776 ?        ZN     0:00 [firefox] <defunct>
```

## plotbar

This tool is inspired by https://github.com/lebinh/goplot.
It visualizes your data as a simple [bar chart](https://en.wikipedia.org/wiki/Bar_chart).

The tool reads data from `STDIN` (the only source so far),
and fetches every entry in format

```
key value
```

It will generate error messages to `STDERR` in case some line doesn't
match the above format and/or their `value` is invalid.

### Examples

Some original examples come from https://github.com/lebinh/goplot.

```
$ dub run dusybox:plotbar < <(2>/dev/null du -s /home/* | sort -n | tail -5 | awk '{print $2,"\t", $1}')
/home/pi.fast :  9 % =========
     /home/pi : 14 % ==============
 /home/btsync : 66 % ==================================================================
 /home/backup :  2 % ==
  /home/ebook :  8 % ========
```

### TODO

- [ ] Support negative data (2-direction bar chart)
