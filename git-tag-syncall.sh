#!/bin/sh
# git alias: tag-syncall
# Fetch tags from origin; conflicts fail and local-only tags are retained.
# --force replaces conflicting tags and prunes local-only tags to match origin.
# Includes initialized submodules recursively; no tags are deleted before fetching.

git config --global alias.tag-syncall '!f() {
  force=;
  case "$#:$1" in 0:) ;;
  1:--force|1:-f) force=1 ;;
  *) echo "Usage: git tag-syncall [--force]" >&2;
  return 2 ;;
  esac;
  if [ -n "$force" ];
  then git fetch --no-tags --no-recurse-submodules --prune origin "+refs/tags/*:refs/tags/*";
  else git fetch --no-tags --no-recurse-submodules origin "refs/tags/*:refs/tags/*";
  fi &&
  { [ -n "$GIT_ALIAS_CHILD" ] ||
  git submodule foreach --recursive "GIT_ALIAS_CHILD=1 git tag-syncall ${force:+--force}";
  };
  };
  f'
