#!/bin/sh
# git alias: fetch-all
# Fetch all configured remotes and their tags without forcing tag replacement.
# Includes initialized submodules recursively.

git config --global alias.fetch-all '!f() {
  [ "$#" -eq 0 ] ||
  { echo "This alias takes no arguments." >&2;
  return 2;
  };
  git fetch --all --tags --recurse-submodules=no &&
  git submodule foreach --recursive '\''git fetch --all --tags --recurse-submodules=no'\'';
  };
  f'
