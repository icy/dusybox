/*
  Purpose : A hello Bash builtin command
  Ideas   : evilrat
  Author  : Ky-Anh Huynh
  Date    : 2017-Oct-21st
  License : MIT
*/

// bash source, builtins.sh
enum BUILTIN_ENABLED = 0x01;

// bash source, shell.h
enum EXECUTION_FAILURE = 1;
enum EXECUTION_SUCCESS = 0;

// bash source, command.h
struct word_desc
{
  char *word; /* Zero terminated string. */
  int flags; /* Flags associated with this word. */
}

// bash source, command.h
/* A linked list of words. */
struct word_list
{
  word_list *next;
  word_desc *word;
}

alias WORD_LIST = word_list;
alias WORD_DESC = word_desc;

// bash source, general.h
alias sh_builtin_func_t = extern(C) int function (word_list *);

// (from http://git.savannah.gnu.org/cgit/bash.git/tree/builtins.h)
struct builtin
{
  char* name;              /* The name that the user types. */
  sh_builtin_func_t func;  /* The address of the invoked function. */
  int flags;               /* One of the #defines above. */
  const char * *long_doc;  /* NULL terminated array of strings. */
  const char *short_doc;   /* Short version of documentation. */
  char *handle;            /* for future use */
}

extern(C) int dz_hello_builtin (WORD_LIST *list)
{
  import std.stdio;
  writeln("Hello, world. It's Hello builtin command writtedn in Dlang.");
  return (EXECUTION_SUCCESS);
}

extern(C) static builtin dz_hello_struct =
{
  name: cast (char*) "dz_hello",
  func: &dz_hello_builtin,
  flags: BUILTIN_ENABLED,
  long_doc: [
    "Hello, it's from Dlang.",
    "",
    "A Hello builtin command written in Dlang."
  ],
  short_doc: cast (char*) "dz_hello",
  handle: null
};
