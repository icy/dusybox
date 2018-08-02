## TOC

* [Why I learn Dlang](#why-i-learn-dlang)
* [My questions on Dlang forum](#my-questions-on-dlang-forum)
* [Interesting dicussions on Dlang forum](#interesting-discussions-on-dlang-forum)
* [Issue reporting and Patches](#issue-reporting-and-patches)
* [Tips and Tricks](#tips-and-tricks)
* [Learning resources](#learning-resources)

## Why I learn Dlang

1. To learn something cool
1. To design some maintainable `DSL` for my jobs
1. To teach my daugher some programming skills ;)
1. Some `Dlang` documentation is just awesome.
   See for example https://github.com/PhilippeSigaud/Pegged/wiki.

## Projects

1. [Vietnamese translation of Dlang Tour](https://github.com/dlang-tour/vietnamese)
1. [Pacapt rewritten in Dlang](https://github.com/icy/pacapt/tree/nd/dmain)

## My questions on Dlang forum

1. [How to list all process directories under /proc/](http://forum.dlang.org/thread/hicrnytiyzcqnqgptmfq@forum.dlang.org):
   Problem with character range when using `Dlang` glob pattern. The current
   implementation of `std_file` doesn't support popular range, e.g, `[a-z]` or `[0-9]`
1. [formattedRead can't work with tab delimeter input](http://forum.dlang.org/thread/gsfsuyyqbvxholmmysgb@forum.dlang.org):
   For some reason, the function doesn't work if there is only tab in input string.
   If there is at least one space, then it works. Tab was not considered
   as a space all the time.
1. [How to skip some field/word in formattedRead](http://forum.dlang.org/post/ttjjucpokokqdjslqncz@forum.dlang.org):
   Ruby has a phantom symbol `_` to discard unwanted item.
   We can do almost the same in `Dlang`? At least there is a work-around.
1. [Convert user input string to Regex](http://forum.dlang.org/post/uroavyktxxagqyebpnkh@forum.dlang.org):
   That's so trivial in `Dlang`. However, I'm not sure if that's safe.
1. [Problem with std.string.strip(): Can't use result in format routine](http://forum.dlang.org/post/dqiupjczsxemllwcckci@forum.dlang.org):
   It's important to remember that `formattedRead` consumes the input range,
   hence you can't use the consumed range for later processing.
1. [Can I skip sub directories with file.dirEntries()](http://forum.dlang.org/post/pajlkcdtpiobfiheoeov@forum.dlang.org):
   Scanning a directory with thousand of files is expensive. We are looking for a way
   to break as early as possible when using `dirEntries()`.
1. [How to modify process environment variables](https://forum.dlang.org/post/ejrooncsvrddrhzehvin@forum.dlang.org)
1. [How to embed static strings to a D program?](https://forum.dlang.org/post/fjidkesfyqlqvtpuizqx@forum.dlang.org)
1. [What does ! mean?](https://forum.dlang.org/post/xtgyzdpvykixwgbagexs@forum.dlang.org)
1. [Writing some built-in functions for Bash, possible?](http://forum.dlang.org/thread/eqpzetxvaaiapabdvyvq@forum.dlang.org)
1. [Trailing comma in variable declaration](https://forum.dlang.org/thread/nnliifmruiaivnwwcvzg@forum.dlang.org)
1. [std.getopt: Unexpected behavior when using incremental options](https://forum.dlang.org/thread/qxpydyjeyouwltkllfhj@forum.dlang.org)
1. [Why does not UFCS work for method defined inside unittest block?](https://forum.dlang.org/thread/zkywlxmtrndlwefdtwoq@forum.dlang.org)

## Interesting dicussions on Dlang forum

1. [agoHow to best implement a DSL?](https://forum.dlang.org/thread/pji0cj$1ufv$1@digitalmars.com)

## Issue reporting and Patches

1. [Exception with nice-curses](https://github.com/mpevnev/nice-curses/issues/2):
    Problem with handling overflow window.
1. [Timeout feature in nice-curses](https://github.com/mpevnev/nice-curses/issues/1):
    Timeout feature to work with user input
1. [Error opening terminal: screen](https://github.com/D-Programming-Deimos/ncurses/issues/35):
    Actual problem is library incompatibility.
1. [dub: Fix anchor link in README.md when viewing package info](https://github.com/dlang/dub-registry/pull/253)
1. [phobos: std.net.curl: Fix getTiming example](https://github.com/dlang/phobos/pull/5760)

## Tips and Tricks

List all _(sub)_packages in the working `dub.sdl`:

```
$ dub list | grep $PWD | awk '{print $1}'   # package names only
$ dub list | grep $PWD                      # more verbose
```

## Learning resources

1. Ali Çehreli - [Programming in D](http://ddili.org/ders/d.en/index.html):
   This is a good book for `Dlang` newbies.
   There are some very basic introductions to different problems
   _(unicode, oop, concurrency)_. Well, `basic` doesn't mean simplicity
   and that's a good start if you have some basic programming experience
   in other language I think.
1. [Dlang Learning Forum](http://forum.dlang.org/group/learn):
   A good place to ask any question about `Dlang` :)
   The community is helpful. However, the forum may be a bit noisy
   and its interface is so basic; it's good to know that the forum was running by
   a `Dlang` application.
1. [Introduction to PEG](https://github.com/PhilippeSigaud/Pegged/wiki):
   This is an impressive documentation about `PEG` (you already know `(e)BNF`, do you?)
   The most useful documentation I've ever read :)
