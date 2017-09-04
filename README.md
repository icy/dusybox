## Description

Simple implementations of System Ultilities in Dlang.

The primary purpose is to understand `Dlang` and to learn about
system programming.

## Tools

### free

Print information about system memory.

It's similar to the `free` command on your `Linux` system.

The original `free` tool is written in `C` and it uses a `bsearch`
routine to look up various fields from `/proc/meminfo`. We don't do
the same in this version: Instead, we use a static `enum` that defines
an ordered list of items to fetch. This order will not be portable
and that's the reason this tool may not work with your kernel.

This tool is tested on `Linux 4.12.8-2`.

TODOs

- [ ] Support different Linux versions
- [ ] Print human-readable memory size

### watch

Execute a shell command and print its output to the standard output device
every second. This is similar to the popular `watch` command.

This tool uses [nice-curses](https://github.com/mpevnev/nice-curses) library.
It can handle some fancy output, but it seems it can't handle big output
and/or any special characters.

TODOs

- [ ] Fix problem with complex command `ps xauw`
- [ ] Exit if output matches some regular expression
- [ ] Exit if user presses `q` or `Q`
- [ ] Tool doesn't work with pipe commands, e.g, `ps x | grep foo`:
      it reports `command not found` error. As a work-around you can
      use `bash -c "ps x | grep ff"` instead.

## Testing

```
$ dub run dusybox:free
$ dub run dusybox:watch -- free -m
```
