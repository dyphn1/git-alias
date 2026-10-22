#!/bin/sh
# git alias: worktree-clean
# Remove clean linked worktrees, keeping the main and current worktrees.
# --force also removes dirty linked worktrees; locked worktrees remain protected.
# Includes initialized submodules recursively; unusual quoted paths are rejected safely.

git config --global alias.worktree-clean '!f() {
  force=;
  case "$#:$1" in 0:) ;;
  1:--force|1:-f) force=1 ;;
  *) echo "Usage: git worktree-clean [--force]" >&2;
  return 2 ;;
  esac;
  if [ -z "$GIT_WORKTREE_CLEAN_CHILD" ];
  then git submodule foreach --recursive "GIT_WORKTREE_CLEAN_CHILD=1 git worktree-clean ${force:+--force}" ||
  return;
  fi;
  current=$(git rev-parse --show-toplevel) ||
  return;
  worktrees=$(git -c core.quotePath=false worktree list --porcelain) ||
  return;
  printf "%s\n" "$worktrees" | sed -n "s/^worktree //p" | sed "1d" | while IFS= read -r path;
  do case "$path" in \"*) echo "Cannot safely process quoted worktree path: $path" >&2;
  exit 1 ;;
  esac;
  [ "$path" = "$current" ] ||
  git worktree remove ${force:+--force} -- "$path" ||
  exit;
  done;
  };
  f'
