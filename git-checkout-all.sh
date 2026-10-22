#!/bin/sh
# git alias: checkout-all
# Discard unstaged tracked changes, restoring files from the index, only with --force.
# Staged changes are preserved; includes initialized submodules recursively.

git config --global alias.checkout-all '!f() {
  case "$#:$1" in 1:--force|1:-f) ;;
  *) echo "Usage: git checkout-all --force (discards unstaged changes)" >&2;
  return 2 ;;
  esac;
  git restore --worktree -- . &&
  git submodule foreach --recursive '\''git restore --worktree -- .'\'';
  };
  f'
