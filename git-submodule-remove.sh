#!/bin/sh
# git alias: submodule-remove
# Usage: git submodule-remove [--force] <root-relative-submodule-path>
# Deinitialize and stage removal of one submodule; --force permits discarding its local changes.
# Retains .git/modules metadata for recovery; does not commit or remove unrelated staged changes.

git config --global alias.submodule-remove '!f() {
  force=;
  case "$1" in --force|-f) force=1;
  shift ;;
  esac;
  [ "$#" -eq 1 ] &&
  [ -n "$1" ] ||
  { echo "Usage: git submodule-remove [--force] <path>" >&2;
  return 2;
  };
  path=$1;
  case "$path" in /*|[A-Za-z]:*|.|..|../*|*/../*|*/..|./*|*/./*|*/.|-*|*\\*) echo "Use an exact root-relative submodule path." >&2;
  return 2 ;;
  esac;
  export GIT_LITERAL_PATHSPECS=1;
  [ "$(git ls-files --format="%(objectmode)" -- "$path")" = 160000 ] &&
  [ "$(git ls-files --format="%(path)" -- "$path")" = "$path" ] ||
  { echo "Not an exact tracked submodule path: $path" >&2;
  return 1;
  };
  git submodule deinit ${force:+--force} -- "$path" &&
  git rm ${force:+--force} -- "$path";
  };
  f'
