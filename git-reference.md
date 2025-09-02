# Git Reference Sheet - Problem-Solving Focus

## Branch Management & Remote Synchronization

### When branches diverge or you need to sync with remote
- **Check divergence status**: `git status` - Shows how many commits ahead/behind you are
- **View commit history graphically**: `git log --oneline --graph -10` - See branch relationships and recent commits
- **Force update remote to match local**: `git push origin main --force-with-lease` - Safely overwrites remote when you're sure your local is correct
- **Move branch to specific commit**: `git reset --hard <commit-hash>` - Points your current branch to any commit (destructive)

### When you accidentally committed to wrong branch
- **Move uncommitted changes to new branch**: `git stash` → `git checkout -b new-branch` → `git stash pop`
- **Move last commit to new branch**: `git branch new-branch` → `git reset --hard HEAD~1` → `git checkout new-branch`
- **Cherry-pick specific commits**: `git cherry-pick <commit-hash>` - Copy a commit to current branch

## Undoing Changes & History Manipulation

### When you need to undo recent work
- **Undo last commit, keep changes**: `git reset --soft HEAD~1` - Moves HEAD back but keeps files staged
- **Undo last commit, lose changes**: `git reset --hard HEAD~1` - Completely removes last commit and changes
- **Undo specific file changes**: `git checkout HEAD -- <file>` - Restores file to last committed state
- **Undo all working directory changes**: `git reset --hard HEAD` - Nuclear option: back to last commit

### When you need to rewrite history (before pushing)
- **Interactive rebase**: `git rebase -i HEAD~3` - Edit, squash, or reorder last 3 commits
- **Amend last commit**: `git commit --amend` - Fix commit message or add forgotten files
- **Squash multiple commits**: During interactive rebase, change `pick` to `squash` for commits to combine

## Merge Conflicts & Collaboration

### When you encounter merge conflicts
- **See conflicted files**: `git status` - Lists files with conflicts
- **Abort merge attempt**: `git merge --abort` - Cancel merge and return to pre-merge state
- **After resolving conflicts**: `git add .` → `git commit` - Stage resolved files and complete merge
- **Use merge tool**: `git mergetool` - Opens configured visual merge tool

### When working with team changes
- **Fetch without merging**: `git fetch origin` - Downloads remote changes without applying them
- **See what's different on remote**: `git diff origin/main` - Compare your branch with remote
- **Rebase instead of merge**: `git rebase origin/main` - Apply your commits on top of remote changes
- **Pull with rebase**: `git pull --rebase` - Avoids merge commits for cleaner history

## Stashing & Temporary Storage

### When you need to quickly switch contexts
- **Save current work**: `git stash` - Temporarily stores uncommitted changes
- **Save with description**: `git stash push -m "working on feature X"` - Named stashes for multiple contexts
- **List all stashes**: `git stash list` - See all saved work contexts
- **Apply latest stash**: `git stash pop` - Restores most recent stash and removes it
- **Apply specific stash**: `git stash apply stash@{2}` - Applies specific stash by index
- **Delete stash**: `git stash drop stash@{1}` - Removes stash without applying

## Commit Management & History

### When you need to understand what happened
- **Detailed commit info**: `git show <commit-hash>` - Full details of a specific commit
- **Find when bug introduced**: `git bisect start` → `git bisect bad` → `git bisect good <commit>` - Binary search for problem
- **See who changed what**: `git blame <file>` - Line-by-line authorship and commit info
- **Search commit messages**: `git log --grep="fix"` - Find commits containing specific text

### When you need to track changes
- **See unstaged changes**: `git diff` - What's different in working directory
- **See staged changes**: `git diff --cached` - What's about to be committed
- **See changes between commits**: `git diff <commit1>..<commit2>` - Compare any two points in history
- **Track file renames**: `git log --follow <file>` - See history even after file moves

## Branch Strategy & Feature Development

### When starting new features
- **Create feature branch**: `git checkout -b feature/new-feature` - Start clean branch from current position
- **Branch from specific commit**: `git checkout -b hotfix/urgent-fix <commit-hash>` - Start branch from any point
- **Switch branches cleanly**: `git checkout main` (stash first if you have changes)

### When finishing features
- **Merge feature branch**: `git checkout main` → `git merge feature/new-feature` - Brings changes to main
- **Delete merged branch**: `git branch -d feature/new-feature` - Cleans up after successful merge
- **Force delete unmerged branch**: `git branch -D experimental-branch` - Removes branch with unmerged work

## Remote Repository Management

### When working with multiple remotes
- **Add second remote**: `git remote add upstream <url>` - Track original repo when you have a fork
- **See all remotes**: `git remote -v` - Lists all configured remote repositories
- **Change remote URL**: `git remote set-url origin <new-url>` - Update where origin points
- **Pull from different remote**: `git pull upstream main` - Get changes from non-origin remote

### When remote gets messy
- **Prune deleted remote branches**: `git remote prune origin` - Cleans up references to deleted remote branches
- **Force fetch**: `git fetch origin --force` - Updates remote references even if they've been rewritten
- **Reset to match remote exactly**: `git reset --hard origin/main` - Make local identical to remote (destructive)

## File and Change Management

### When you need to selectively stage changes
- **Stage parts of file**: `git add -p <file>` - Interactive staging of hunks within a file
- **Unstage file**: `git reset HEAD <file>` - Remove file from staging area
- **Stage all changes**: `git add .` - Stage everything in current directory and subdirectories
- **Stage only tracked files**: `git add -u` - Stage changes to files Git already knows about

### When dealing with large files or sensitive data
- **Remove file from history**: `git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch <file>'` - Completely remove file from all history
- **Stop tracking file**: `git rm --cached <file>` - Remove from Git but keep local copy
- **Add to gitignore retroactively**: Add to `.gitignore` → `git rm --cached <file>` → `git commit`

## Emergency Situations & Recovery

### When everything seems broken
- **See what you just did**: `git reflog` - Shows every HEAD movement, even after destructive operations
- **Recover lost commits**: `git checkout <commit-from-reflog>` → `git checkout -b recovery-branch` - Restore from reflog
- **Find lost work**: `git fsck --lost-found` - Finds orphaned commits
- **Clean working directory**: `git clean -fd` - Removes untracked files and directories

### When you pushed something you shouldn't have
- **Revert public commit**: `git revert <commit-hash>` - Creates new commit that undoes changes (safe for shared repos)
- **Force push after local fix**: `git push origin main --force-with-lease` - Updates remote after local history rewrite
- **Emergency: Remove sensitive data**: Contact your Git hosting provider immediately, force push won't fully remove from their systems

## Advanced Workflows

### When you need surgical precision
- **Interactive staging**: `git add -i` - Menu-driven staging with multiple options
- **Partial file checkout**: `git checkout <branch> -- <file>` - Get one file from another branch
- **Temporary commit**: `git commit -m "WIP: temp save"` → work → `git commit --amend` - Save progress then clean up
- **Split large commit**: `git reset HEAD~1` → `git add -p` → multiple smaller commits

### When working with patches
- **Create patch file**: `git format-patch -1 <commit-hash>` - Export commit as email-ready patch
- **Apply patch**: `git apply <patch-file>` - Apply changes from patch file
- **Cherry-pick from patch**: `git am <patch-file>` - Apply patch as new commit

## Quick Diagnostics

### Essential status commands
- **Full situation report**: `git status` → `git log --oneline -5` → `git remote -v`
- **See what's staged**: `git diff --cached --name-only`
- **See branch relationships**: `git log --oneline --graph --all -10`
- **Find specific changes**: `git log -p --grep="keyword"` - Search commits with their diffs

### Performance and maintenance
- **Check repository size**: `git count-objects -vH` - See repository statistics
- **Garbage collect**: `git gc --aggressive` - Optimize repository storage
- **Verify repository**: `git fsck` - Check repository integrity

## Common Problem Scenarios

### "I made commits on main instead of a feature branch"
1. `git branch feature/my-work` (create branch at current position)
2. `git reset --hard origin/main` (move main back to remote)
3. `git checkout feature/my-work` (switch to your work)

### "I need to sync my fork with upstream changes"
1. `git remote add upstream <original-repo-url>` (if not already added)
2. `git fetch upstream`
3. `git checkout main`
4. `git merge upstream/main`
5. `git push origin main`

### "I accidentally merged the wrong branch"
1. `git log --oneline` (find the commit before merge)
2. `git reset --hard <commit-before-merge>`
3. `git push origin main --force-with-lease` (if already pushed)

### "My branch is way behind main and has conflicts"
1. `git fetch origin`
2. `git rebase origin/main` (or `git merge origin/main` if you prefer merge commits)
3. Resolve conflicts → `git add .` → `git rebase --continue`
4. `git push origin feature-branch --force-with-lease`

### "I need to test someone else's branch quickly"
1. `git fetch origin`
2. `git checkout -b test-branch origin/their-branch`
3. Test and work
4. `git checkout main` → `git branch -d test-branch` (cleanup)

## Safety Tips

- **Always use `--force-with-lease`** instead of `--force` when force pushing
- **Backup before destructive operations**: `git branch backup-$(date +%Y%m%d)` 
- **Test commands on copies first** when learning new Git operations
- **Use `git stash` liberally** - it's better to stash too often than lose work
- **Check `git status`** before and after major operations to confirm results