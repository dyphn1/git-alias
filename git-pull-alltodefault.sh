#!/bin/sh
# git alias: pull-alltodefault
# Check out each repository’s own origin default branch (fallback: origin/main, origin/master).
# Pull using fast-forward only; includes initialized submodules recursively; local changes are not forced.

git config --global alias.pull-alltodefault '!f() {
  [ "$#" -eq 0 ] ||
  { echo "This alias takes no arguments." >&2;
  return 2;
  };
  branch=$(git symbolic-ref -q --short refs/remotes/origin/HEAD) ||
  { if git show-ref --verify --quiet refs/remotes/origin/main;
  then branch=origin/main;
  elif git show-ref --verify --quiet refs/remotes/origin/master;
  then branch=origin/master;
  else echo "Cannot determine origin default branch." >&2;
  return 1;
  fi;
  };
  branch=${branch#origin/};
  if git show-ref --verify --quiet "refs/heads/$branch";
  then git -c submodule.recurse=false checkout --no-guess "$branch";
  else git -c submodule.recurse=false checkout --track -b "$branch" "origin/$branch";
  fi ||
  return;
  git -c submodule.recurse=false pull --ff-only --no-rebase origin "$branch" &&
  { [ -n "$GIT_ALIAS_CHILD" ] ||
  git submodule foreach --recursive "GIT_ALIAS_CHILD=1 git pull-alltodefault";
  };
  };
  f'
