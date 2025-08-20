# Git worktrees: a clean, repeatable workflow (feature → back to `main`)

This guide shows a **safe, step-by-step** way to use `git worktree` to develop a feature in a separate working folder, keep it rebased, and integrate it back into `main` without leaving mess behind.

> Works with Git ≥ 2.5 (recommended 2.38+). Assumes your default remote is `origin` and your mainline branch is `main`.

---

## 0) One-time prep (recommended)

```bash
# From your primary repo folder (the one that tracks main)
git fetch origin --prune                             # up-to-date remotes
git config pull.ff only                              # avoid accidental merge commits
git config rebase.autoStash true                     # stash unstaged work before rebase
git config branch.autoSetupRebase always             # new branches rebase by default
```

(Optional) keep worktrees in a dedicated folder next to your main repo:

```bash
# layout suggestion
~/code/myapp/            # main working copy (tracks 'main')
~/code/myapp.worktrees/  # all feature worktrees live here
mkdir -p ~/code/myapp.worktrees
```

---

## 1) Create a feature worktree

Create a **separate folder** with its own checkout, on a **new branch** that starts from the latest `origin/main`:

```bash
cd ~/code/myapp
git fetch origin --prune
git worktree add -b feature/amazing \
  ~/code/myapp.worktrees/amazing \
  origin/main
```

What this does:

* Makes a new directory `~/code/myapp.worktrees/amazing`
* Checks out a new branch `feature/amazing` there, starting at `origin/main`
* Keeps your main working copy free to do other things

> Tip: each worktree has its own index and working files but **shares the same `.git` object store**, saving space and speeding up operations.

---

## 2) Do the work

In the feature folder:

```bash
cd ~/code/myapp.worktrees/amazing
# ... edit files
git status
git add -A
git commit -m "Implement amazing thing: step 1"
```

Create the remote branch the first time you push:

```bash
git push -u origin feature/amazing
```

---

## 3) Keep your branch current (clean rebases)

Rebase your feature branch on top of the latest `main` regularly to avoid painful merges later:

```bash
# from inside the feature worktree
git fetch origin --prune
git rebase origin/main   # replay your commits on top of the updated main
# fix any conflicts, then:
git push --force-with-lease
```

**Why `--force-with-lease`?** It refuses to overwrite remote work if someone else pushed after you—safer than `--force`.

---

## 4) Open a Pull Request (or compare) when ready

Since you already pushed `feature/amazing`, open a PR from `feature/amazing` → `main` on your host (GitHub/GitLab/etc.).

Run your tests/CI here. If reviewers ask for changes, just keep committing and (if needed) rebasing as in step 3.

---

## 5) Integrate back into `main` (no surprises)

You have two clean options. Pick one **and stick to it** for consistency.

### Option A — Fast-forward (linear history; requires branch is up to date)

From your **main working copy** (the original repo folder):

```bash
cd ~/code/myapp
git fetch origin --prune
git checkout main
git pull --ff-only
git merge --ff-only feature/amazing     # fast-forward merge (no merge commit)
git push
```

### Option B — Squash merge (one tidy commit)

From the main working copy:

```bash
git fetch origin --prune
git checkout main
git pull --ff-only
git merge --squash feature/amazing
git commit -m "feat: amazing (squashed)"
git push
```

> If you merged via the hosting provider UI, just **pull** locally afterwards:
>
> ```bash
> cd ~/code/myapp
> git checkout main
> git pull --ff-only
> ```

---

## 6) Delete the feature branch and **cleanly remove** the worktree

Once merged:

```bash
# Remove the worktree directory (this also releases internal refs)
git worktree remove ~/code/myapp.worktrees/amazing

# Delete the local branch (only after removing the worktree that was using it)
git branch -d feature/amazing

# Delete the remote branch
git push origin --delete feature/amazing

# Prune any stale internal worktree metadata
git worktree prune
```

> If Git refuses `branch -d` (unmerged work), use `-D` only when you’re **certain** it’s merged or no longer needed.

---

## 7) Repeatable helper: one-command tasks

Drop these **shell functions** in your `.bashrc` / `.zshrc` to speed things up.

```bash
# Create a new feature worktree from origin/main
wt-new() {
  local name="$1"
  local root="${2:-$PWD}"
  local wtroot="${3:-$root.worktrees}"
  test -z "$name" && { echo "usage: wt-new <short-name> [repo-root] [worktrees-root]"; return 1; }
  mkdir -p "$wtroot"
  ( cd "$root" || exit 1
    git fetch origin --prune || exit 1
    git worktree add -b "feature/$name" "$wtroot/$name" origin/main
  )
  echo "Created $wtroot/$name on branch feature/$name"
}

# Rebase feature worktree onto latest origin/main
wt-rebase() {
  local dir="${1:-$PWD}"
  ( cd "$dir" || exit 1
    git fetch origin --prune || exit 1
    git rebase origin/main || exit 1
    git push --force-with-lease
  )
}

# Integrate feature into main from your main repo folder (fast-forward)
wt-ff-merge() {
  local branch="feature/${1:?usage: wt-ff-merge <short-name>}"
  local root="${2:-$PWD}"
  ( cd "$root" || exit 1
    git fetch origin --prune || exit 1
    git checkout main && git pull --ff-only || exit 1
    git merge --ff-only "$branch" || exit 1
    git push || exit 1
  )
}

# Remove worktree + branches after merge
wt-clean() {
  local name="${1:?usage: wt-clean <short-name>}"
  local root="${2:-$PWD}"
  local wtroot="${3:-$root.worktrees}"
  ( cd "$root" || exit 1
    git worktree remove "$wtroot/$name"
    git branch -d "feature/$name" || git branch -D "feature/$name"
    git push origin --delete "feature/$name" 2>/dev/null || true
    git worktree prune
  )
}
```

**Typical flow with helpers:**

```bash
cd ~/code/myapp
wt-new amazing
cd ~/code/myapp.worktrees/amazing
# ... commit work ...
git push -u origin feature/amazing
# ... open PR ...
wt-rebase ~/code/myapp.worktrees/amazing   # keep it fresh during review
cd ~/code/myapp && wt-ff-merge amazing     # integrate
wt-clean amazing                           # tidy up
```

---

## Common pitfalls & fixes

* **“Working tree already exists”** when creating a worktree
  → You likely reused the same path/branch. Either choose a new folder/branch, or remove the old one:
  `git worktree remove <path>; git worktree prune`.

* **“This branch is checked out at …”** when deleting a branch
  → A worktree is still using it. Run:
  `git worktree list` (see where it’s checked out), then `git worktree remove <that-path>` and retry `git branch -d`.

* **Forgot to push the feature branch** before opening a PR
  → From the feature folder: `git push -u origin feature/…`.

* **Merge blocked: branch behind `main`**
  → Rebase and force-push (with lease):
  `git fetch origin; git rebase origin/main; git push --force-with-lease`.

* **Accidentally created commits on the main working copy**
  → If they belong to the feature:
  `git switch feature/amazing` and `git cherry-pick <bad..good>`
  or interactively rebase to move them. Keep main clean.

* **Orphaned locks/metadata after a crash**
  → `git worktree prune` and (if needed) manually delete the abandoned folder.

---

## Quick reference

```bash
# List worktrees
git worktree list

# Add worktree at a path (new branch from main)
git worktree add -b feature/name /path/to/wt origin/main

# Remove worktree at path (does not delete branch)
git worktree remove /path/to/wt

# Update feature with latest main
git fetch origin --prune
git rebase origin/main
git push --force-with-lease

# Merge feature into main (fast-forward)
git checkout main
git pull --ff-only
git merge --ff-only feature/name
git push
```
