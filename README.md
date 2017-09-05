## Description

Simple implementations of System Ultilities in Dlang.

The primary purpose is to understand `Dlang` and to learn about
system programming.

## TOC

* [free](#free)
* [watch](#watch)
* [plotbar](#plotbar)

## free

Print information about system memory.

It's similar to the `free` command on your `Linux` system.

The original `free` tool is written in `C` and it uses a `bsearch`
routine to look up various fields from `/proc/meminfo`. We don't do
the same in this version: Instead, we use a static `enum` that defines
an ordered list of items to fetch. This order will not be portable
and that's the reason this tool may not work with your kernel.

This tool is tested on `Linux 4.12.8-2`.

### TODO

- [ ] Support different Linux versions
- [ ] Print human-readable memory size

### Example

```
$ dub run dusybox:free
```

## watch

Execute a shell command and print its output to the standard output device
every second. This is similar to the popular `watch` command.

This tool uses [nice-curses](https://github.com/mpevnev/nice-curses) library.
It can handle some fancy output, but it seems it can't handle big output
and/or any special characters.

### TODO

- [ ] Fix problem with complex command `ps xauw`
- [ ] Exit if output matches some regular expression
- [ ] Exit if user presses `q` or `Q`
- [ ] Tool doesn't work with pipe commands, e.g, `ps x | grep foo`:
      it reports `command not found` error. As a work-around you can
      use `bash -c "ps x | grep ff"` instead.

### Examples

```
$ dub run dusybox:watch -- free -m
$ dub run dusybox:watch -- ps x
```

## plotbar

This tool is inspired by https://github.com/lebinh/goplot.
It visulizes your data as a simple [bar chart](https://en.wikipedia.org/wiki/Bar_chart).

Input data format

```
key value
```

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
