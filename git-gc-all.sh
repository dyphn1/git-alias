#!/bin/sh
# git alias: gc-all
# Run normal Git garbage collection, retaining normal reflog/prune grace periods.
# Does not delete/synchronize tags; includes initialized submodules recursively.

git config --global alias.gc-all '!f() {
  [ "$#" -eq 0 ] ||
  { echo "This alias takes no arguments." >&2;
  return 2;
  };
  git gc &&
  git submodule foreach --recursive '\''git gc'\'';
  };
  f'
