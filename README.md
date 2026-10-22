# Git aliases

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Run the corresponding `git-*.sh` installer in Git Bash to register an alias in your global Git configuration. Installers only update configuration; they do not run cleanup operations. All `*-all` aliases, `branch-cleanlocals`, `tag-syncall`, and `worktree-clean` include initialized submodules recursively. `submodule-addall` initializes submodules at every level.

| Alias | Default behavior | `--force` (also accepts `-f`) |
| --- | --- | --- |
| `branch-cleanlocals` | Delete branches using `git branch -d`; preserve the current branch and branches checked out in other worktrees; succeed when there are no branches to delete | Use `-D` to allow deletion of unmerged branches |
| `checkout-all` | Refuse to run to prevent accidental loss of changes | Restore tracked files from the index, discarding unstaged changes while preserving staged changes |
| `clean-all` | Preview removal of untracked and ignored files and directories | Perform deletion; protect directories containing nested Git repositories |
| `fetch-all` | Fetch branches and tags from all remotes without forcing tag replacement | Not supported |
| `gc-all` | Run normal `git gc` with the configured recovery grace periods; do not delete tags | Not supported |
| `pull-alltodefault` | Use each repository's own origin/HEAD, falling back to origin/main and then origin/master; allow fast-forward pulls only | Not supported |
| `pull-alltomaster` | Check out or create local master and pull from origin/master; allow fast-forward pulls only | Not supported |
| `submodule-addall` | Initialize submodules using existing gitlinks and .gitmodules, then update them to their recorded commits; propagate errors | Not supported |
| `submodule-remove <path>` | Deinitialize and stage removal of the specified submodule; reject local modifications, retain repository metadata, and do not commit automatically | Place before the path to allow discarding that submodule's local changes |
| `tag-syncall` | Fetch tags from origin; preserve local-only tags and report conflicts | Replace conflicting tags and delete local tags that do not exist on origin |
| `worktree-clean` | Remove clean linked worktrees; preserve the main and current worktrees | Allow removal of dirty worktrees; locked worktrees remain protected |

Batch operations stop on errors. Operations already completed are not rolled back. Git shell aliases run from the repository root; `submodule-remove` requires an exact path relative to that root. Default-branch detection for pulls relies on local origin remote-tracking refs; run `fetch-all` first to update them. `worktree-clean` rejects unusual paths that require quoting in Git porcelain output; handle those worktrees individually.

Run verification using temporary repositories and an isolated Git configuration:

```sh
sh tests/test-aliases.sh
```
