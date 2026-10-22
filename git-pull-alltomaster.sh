#!/bin/sh
# git alias: pull-alltomaster
# Check out master and pull origin/master using fast-forward only.
# Includes initialized submodules recursively; local changes are not forced.

git config --global alias.pull-alltomaster '!f() {
  [ "$#" -eq 0 ] ||
  { echo "This alias takes no arguments." >&2;
  return 2;
  };
  if git show-ref --verify --quiet refs/heads/master;
  then git -c submodule.recurse=false checkout --no-guess master;
  else git -c submodule.recurse=false checkout --track -b master origin/master;
  fi ||
  return;
  git -c submodule.recurse=false pull --ff-only --no-rebase origin master &&
  { [ -n "$GIT_ALIAS_CHILD" ] ||
  git submodule foreach --recursive "GIT_ALIAS_CHILD=1 git pull-alltomaster";
  };
  };
  f'
