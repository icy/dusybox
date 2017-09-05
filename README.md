## Description

Simple implementations of System Ultilities in Dlang.

The primary purpose is to understand `Dlang`
and to learn system programming.

* [free](#free) Display system memory information
* [watch](#watch) Watch command output
  * [TODO](#todo-1)
  * [Examples](#examples-1)
* [plotbar](#plotbar) Draw 2-d bar chart
  * [TODO](#todo-2)
  * [Examples](#examples-2)
* [jq](#jq) Simple and not stupid `json` query tool
  * [TODO](#todo-3)
  * [Examples](#examples-3)

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

### Examples

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

- [ ] Redirect output from `stderr`
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

...
:: Reached maximum number of interation (2) at 2017-Sep-05 18:04:47.0811478.
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

### TODO

- [ ] Support tab delimeter in `key value` line
- [ ] Support negative data (2-direction bar chart)
- [x] Display actual value after the bar
- [x] Set the minium percent number to display (`-m min`)
- [ ] Display last n items (like `sort | tail`)
- [ ] Sort the output (if the input is sorted)
- [x] Additive mode (Sum of duplicated items)
- [x] Fix bug when parsing input data (previous `value` is reused.)

### Examples

Find the biggest folder items, display ones consume great than `2%` of total storage.
_(The idea for this example comes from https://github.com/lebinh/goplot.)_
Please note that you can't use `\t` character in this example: The input parser
doesn't understand tab.

```
$ dub run dusybox:plotbar -- -m 2 < <(2>/dev/null du -s /home/* | awk '{printf("%s %s\n", $2, $1)}')

/home/pi.fast :  9 % ========= (9466072)
     /home/pi : 13 % ============= (14541032)
 /home/btsync : 64 % ================================================================ (69425660)
  /home/ebook :  8 % ======== (8600288)
 /home/backup :  2 % == (2615004)
```

Display the `ElasticSearch` indices the have most documents.
Skip all indices that consumes less than `2%` in the total number of documents.

```
$ curl -s 'elk.example.net:9201/_cat/indices?h=index,docs.count'" | dusybox_plotbar -m 2

                aws-lambda-test-uat-test-20170824 :  9 % ========= (4986415)
     api-gateway-execution-logs-test-uat-20170824 :  4 % ==== (2486179)
                aws-lambda-test-uat-test-20170824 :  2 % == (1177304)
                aws-lambda-test-dev-test-20170815 :  4 % ==== (2227446)
```

Display the biggest indexes (in stored size):

```
$ curl -s 'elk.example.net:9201/_cat/indices?h=index,store.size&bytes=k'" | dusybox_plotbar -m 2

                aws-lambda-test-uat-test-20170824 :  2 % == (2847921)
                                     emr-20170904 :  2 % == (3364511)
                aws-lambda-test-uat-test-20170824 :  4 % ==== (5544297)
                aws-lambda-test-uat-test-20170821 :  2 % == (2853427)
```

Now find the biggest source (by discarding date suffixes):

```
$ curl -s 'elk.example.net:9201/_cat/indices?h=index,store.size&bytes=k'" \
  | sed -re 's#-[0-9]{8}##g' \
  | dusybox_plotbar -m 5 2>/dev/null

                         aws-lambda-test-uat-test :  5 % ===== (3145751)
                                              emr : 11 % =========== (6974423)
                        aws-lambda-test-uat-test2 : 11 % =========== (6622399)
                       cloudtrail-defaultloggroup : 11 % =========== (6726637)
```

Find the package that has most files on `ArchLinux` system

```
$ pacman -Ql | grep -vE '/$' | awk '{printf("%s 1\n", $1 );}' | dusybox_plotbar -m 2
                          evince :  2 % == (3058)
                         efl-git :  2 % == (3563)
                         python2 :  3 % === (4646)
              adwaita-icon-theme :  4 % ==== (5426)
                            mono :  2 % == (2443)
                           linux :  3 % === (3984)
                   linux-headers :  9 % ========= (12296)
                          python :  5 % ===== (6784)
                             ghc :  4 % ==== (5728)
               claws-mail-themes :  3 % === (4689)
                         openssl :  2 % == (3252)
                             qt4 :  3 % === (3825)
                            perl :  2 % == (2393)
                          libxcb :  2 % == (2371)
                         ncurses :  3 % === (3678)
                           cmake :  2 % == (2267)
                       man-pages :  2 % == (3491)
                             gcc :  2 % == (2198)
```

## jq

This is not https://github.com/stedolan/jq.

Instead, this tool reads line from `STDIN` and considers
each line as a `JSON` string. This is useful as I need to process
multiple `JSON` lines from `nginx` and/or `ELK` system.

If input line can be parsed, the result will be printed to `stdout`
_(if the tool has not any argument)_, or each item from arguments
is looked up in the final `JSON` object. If the argument is

```
dusybox_jq .foo bar
```

then the `.foo` is used as a lookup key, while `bar` is printed literally.

### TODO

- [ ] Handle delimeter
- [ ] Handle format string
- [ ] Handle object other than integer and/or string..
- [ ] Nested support
- [x] Literraly support
- [x] Process lines from `STDIN` as invidual documents.
      See also https://github.com/stedolan/jq/issues/744.

## Examples

Print key `.a` and `.b`, print `1` literally.

```
$ echo '{"a": 9, "b": {"c": 1}}' | dub run dusybox:jq -- .a 1 .b
9       1       {"c":1}
```

Print the original `JSON` string

```
$ echo '{"a": 9, "b": {"c": 1}}' | dub run dusybox:jq --
'{"a": 9, "b": {"c": 1}}'
```

Generate simple statistics from `nginx` access log file.
The format of log file is similar to
  [this one](https://github.com/icy/docker/blob/fluentd/context/etc/nginx/nginx.conf).

```
$ dub run dusybox:jq -- .host 1 < /home/pi/df/acces.log | ./dusybox_plotbar -m 2
     kibana.int.example.net : 25 % ========================= (269)
    airflow.dev.example.net :  3 % === (33)
    grafana.int.example.net : 70 % ====================================================================== (755)
airflow.staging.example.net :  3 % === (28)
```

How about the requests or statuses?

```
$ dub run dusybox:jq -- .request_uri 1 < /home/pi/df/acces.log | ./dusybox_plotbar -m 2
/api/console/proxy?path=_aliases&method=GET :  4 % ==== (44)
/api/console/proxy?path=_mapping&method=GET :  4 % ==== (44)
                  /api/datasources/proxy/16 : 34 % ================================== (364)
                  /api/datasources/proxy/14 : 12 % ============ (132)
                  /api/datasources/proxy/13 :  5 % ===== (55)
                    /elasticsearch/_msearch :  4 % ==== (40)
                  /api/datasources/proxy/12 : 11 % =========== (122)

$ dub run dusybox:jq -- .status 1 < /home/pi/df/acces.log | ./dusybox_plotbar -m 2
200 : 93 % ============================================================================================= (1013)
304 :  4 % ==== (43)
```
