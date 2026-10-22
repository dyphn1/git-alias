#!/bin/sh
set -eu
alias_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
testdir=$(mktemp -d)
export GIT_CONFIG_GLOBAL="$testdir/gitconfig" GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=Test GIT_AUTHOR_EMAIL=test@example.invalid
export GIT_COMMITTER_NAME=Test GIT_COMMITTER_EMAIL=test@example.invalid
export GIT_CONFIG_COUNT=3 GIT_CONFIG_KEY_0=commit.gpgsign GIT_CONFIG_VALUE_0=false
export GIT_CONFIG_KEY_1=protocol.file.allow GIT_CONFIG_VALUE_1=always
export GIT_CONFIG_KEY_2=init.defaultBranch GIT_CONFIG_VALUE_2=master
for script in "$alias_dir"/*.sh; do sh -n "$script"; sh "$script"; done
cd "$testdir"
git init -q repo
cd repo
for alias in branch-cleanlocals clean-all fetch-all gc-all pull-alltodefault pull-alltomaster submodule-addall submodule-remove tag-syncall worktree-clean checkout-all; do
  value=$(git config "alias.$alias" | cut -c2-)
  sh -n -c "$value"
  if git "$alias" --invalid >"$testdir/invalid.log" 2>&1; then echo "Unexpected argument accepted: $alias"; exit 1; fi
done
echo 'PASS: installer syntax and invalid arguments'
git branch-cleanlocals
git gc-all
git commit -qm initial --allow-empty
printf 'keep\n' > tracked
printf 'ignored\n' > .gitignore
git add tracked .gitignore
git commit -qm files
printf 'modified\n' > tracked
if git checkout-all; then exit 1; fi
test "$(cat tracked)" = modified
git checkout-all --force
test "$(cat tracked)" = keep
printf 'staged\n' > tracked
git add tracked
printf 'unstaged\n' > tracked
git checkout-all --force
test "$(cat tracked)" = staged
git reset --hard -q HEAD
mkdir untracked
printf data > untracked/data
printf data > ignored
git clean-all
test -f untracked/data && test -f ignored
git clean-all --force
test ! -e untracked && test ! -e ignored
git branch merged
git branch-cleanlocals
if git show-ref --verify --quiet refs/heads/merged; then echo "Unexpected ref retained" >&2; exit 1; fi
git checkout -qb unmerged
git commit -qm unique --allow-empty
git checkout -q master
if git branch-cleanlocals; then exit 1; fi
git show-ref --verify --quiet refs/heads/unmerged
git branch-cleanlocals --force
if git show-ref --verify --quiet refs/heads/unmerged; then echo "Unexpected ref retained" >&2; exit 1; fi
git branch-cleanlocals
git tag local-only
git gc-all
git show-ref --verify --quiet refs/tags/local-only
echo 'PASS: branch, restore, clean and gc protections'
cd ..
git init -q --bare origin.git
git -C repo remote add origin ../origin.git
git -C repo push -q origin master
git clone -q origin.git source
git -C source tag remote-tag
git -C source push -q origin refs/tags/remote-tag
cd repo
git tag-syncall
git show-ref --verify --quiet refs/tags/local-only
git show-ref --verify --quiet refs/tags/remote-tag
git tag -f remote-tag HEAD~1
if git tag-syncall; then exit 1; fi
git tag-syncall --force
if git show-ref --verify --quiet refs/tags/local-only; then echo "Unexpected ref retained" >&2; exit 1; fi
test "$(git rev-parse remote-tag)" = "$(git rev-parse HEAD)"
git fetch-all
echo 'PASS: tag preservation, conflict and forced synchronization'
cd ..
git init -q --bare second.git
git -C repo remote add second ../second.git
git -C repo push -q second master
git -C repo fetch-all
git -C repo show-ref --verify --quiet refs/remotes/second/master
git -C source checkout -qb main
git -C source push -q origin main
git -C origin.git symbolic-ref HEAD refs/heads/main
git init -q parent
cd parent
git commit -qm initial --allow-empty
git submodule add -q ../origin.git 'module space'
git commit -qam submodule
git init -q --bare ../parent.git
git remote add origin ../parent.git
git push -qu origin master
git remote set-head origin master
git -C 'module space' remote set-head origin main
git -C 'module space' checkout -q --detach
git -C 'module space' branch -D main
git pull-alltodefault
test "$(git branch --show-current)" = master
test "$(git -C 'module space' branch --show-current)" = main
git -C 'module space' branch disposable
git checkout -q --detach
git branch -D master
git branch-cleanlocals
test -z "$(git -C 'module space' branch --list disposable)"
git checkout -qb master
git submodule-addall
git submodule-addall
printf changed > 'module space/local-data'
if git submodule-remove 'module space'; then exit 1; fi
test -f 'module space/local-data'
if git submodule-remove '.'; then exit 1; fi
if git submodule-remove '*'; then exit 1; fi
before=$(git rev-parse HEAD)
git submodule-remove --force 'module space'
test "$(git rev-parse HEAD)" = "$before"
test -z "$(git ls-files -- 'module space')"
test -d '.git/modules/module space'
echo 'PASS: per-repo defaults, branchless traversal, submodule init/removal'
cd ../repo
git worktree add -qb linked '../linked worktree'
git branch-cleanlocals --force
git show-ref --verify --quiet refs/heads/linked
printf data > '../linked worktree/dirty'
if git worktree-clean; then exit 1; fi
test -f '../linked worktree/dirty'
git worktree-clean --force
test ! -e '../linked worktree'
git worktree add -qb locked ../locked
git worktree lock ../locked
if git worktree-clean --force; then exit 1; fi
test -d ../locked
git worktree unlock ../locked
git -C ../locked worktree-clean
test -d ../locked
git worktree-clean
test ! -e ../locked
echo 'PASS: dirty/locked/current worktree protection and force'

# A nested module must be visited exactly once, with force forwarded throughout.
cd "$testdir/source"
git submodule add -q ../second.git 'nested module'
git commit -qam nested
git push -q origin main
cd "$testdir"
git init -q nested-parent
cd nested-parent
git commit -qm initial --allow-empty
git submodule add -q ../origin.git 'outer module'
git commit -qam outer
git submodule-addall
printf keep > 'outer module/trash'
printf keep > 'outer module/nested module/trash'
git clean-all
test -f 'outer module/trash'
test -f 'outer module/nested module/trash'
git clean-all --force
test ! -f 'outer module/trash'
test ! -f 'outer module/nested module/trash'
git tag nested-tag
git -C 'outer module' tag nested-tag
git -C 'outer module/nested module' tag nested-tag
output=$(git gc-all)
test "$(printf '%s\n' "$output" | sed -n '/^Entering /p' | wc -l)" -eq 2
git -C 'outer module/nested module' show-ref --verify --quiet refs/tags/nested-tag
git fetch-all
# Local divergence must never create a merge commit.
cd "$testdir/repo"
git commit -qm local-only --allow-empty
git -C ../source checkout -q master
git -C ../source commit -qm remote-only --allow-empty
git -C ../source push -q origin master
before=$(git rev-parse HEAD)
if git pull-alltomaster; then exit 1; fi
test "$(git rev-parse HEAD)" = "$before"
git checkout -qb scratch
# Missing origin default information must fail without switching branches.
git init -q "$testdir/no-default"
git -C "$testdir/no-default" commit -qm initial --allow-empty
if git -C "$testdir/no-default" pull-alltodefault; then exit 1; fi
test "$(git -C "$testdir/no-default" branch --show-current)" = master
echo 'PASS: nested traversal, force forwarding, divergence and missing origin'

echo "All tests passed; fixtures: $testdir"
