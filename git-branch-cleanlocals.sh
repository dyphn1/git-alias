#!/bin/sh
# git alias: branch-cleanlocals
# Delete merged local branches except the current/linked-worktree branches; --force also deletes unmerged branches.
# Includes initialized submodules recursively; empty branch lists succeed.

git config --global alias.branch-cleanlocals '!f() {
  force=;
  case "$#:$1" in 0:) ;;
  1:--force|1:-f) force=1 ;;
  *) echo "Usage: git branch-cleanlocals [--force]" >&2;
  return 2 ;;
  esac;
  mode=-d;
  [ -z "$force" ] ||
  mode=-D;
  branches=$(git for-each-ref --format="%(refname:short)" refs/heads) ||
  return;
  current=$(git symbolic-ref -q --short HEAD) ||
  current=;
  printf "%s\n" "$branches" | while IFS= read -r branch;
  do [ -n "$branch" ] ||
  continue;
  [ "$branch" != "$current" ] ||
  continue;
  [ -z "$(git for-each-ref --format="%(worktreepath)" "refs/heads/$branch")" ] ||
  continue;
  git branch "$mode" -- "$branch" ||
  exit;
  done &&
  { [ -n "$GIT_ALIAS_CHILD" ] ||
  git submodule foreach --recursive "GIT_ALIAS_CHILD=1 git branch-cleanlocals ${force:+--force}";
  };
  };
  f'
