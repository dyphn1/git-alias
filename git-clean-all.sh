#!/bin/sh
# git alias: clean-all
# Preview removal of untracked and ignored files/directories; --force performs deletion.
# Includes initialized submodules recursively; nested Git repositories are protected.

git config --global alias.clean-all '!f() {
  force=;
  case "$#:$1" in 0:) ;;
  1:--force|1:-f) force=1 ;;
  *) echo "Usage: git clean-all [--force]" >&2;
  return 2 ;;
  esac;
  mode=-ndx;
  [ -z "$force" ] ||
  mode=-fdx;
  git clean "$mode" &&
  { [ -n "$GIT_ALIAS_CHILD" ] ||
  git submodule foreach --recursive "GIT_ALIAS_CHILD=1 git clean-all ${force:+--force}";
  };
  };
  f'
