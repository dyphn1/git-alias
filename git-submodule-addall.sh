#!/bin/sh
# git alias: submodule-addall
# Initialize and clone registered submodules from .gitmodules recursively.
# Existing submodules are updated to recorded commits; conflicting local changes cause an error.

git config --global alias.submodule-addall '!f() {
  [ "$#" -eq 0 ] ||
  { echo "This alias takes no arguments." >&2;
  return 2;
  };
  git submodule update --init --recursive;
  };
  f'
