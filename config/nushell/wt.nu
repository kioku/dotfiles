# wt.nu — Git worktree management
#
# Manages worktrees under `.worktrees/` in the repository root.
#
# Usage (after `use wt.nu *`):
#   wt add <branch> [-b base]    Create a worktree and cd into it
#   wt remove [branch] [--force] Remove a worktree and delete its local branch
#   wt go <branch>               Jump to an existing worktree
#   wt list                      List all worktrees as a table

# ---------------------------------------------------------------------------
# Helpers (module-private)
# ---------------------------------------------------------------------------

# Root of the main working tree (resolves correctly from inside a worktree).
def repo-root [] {
    let common = (git rev-parse --git-common-dir | str trim)
    if $common == ".git" {
        git rev-parse --show-toplevel | str trim
    } else {
        # common is an absolute path to the shared .git dir — parent is the repo root
        $common | path dirname
    }
}

# Sanitize a branch name into a safe directory name (e.g. feature/auth → feature-auth).
def dir-name [branch: string] {
    $branch | str replace --all '/' '-'
}

# Parse `git worktree list --porcelain` into a structured table.
def parse-worktrees [] {
    let raw = (git worktree list --porcelain)
    if ($raw | str trim | is-empty) { return [] }

    $raw
    | split row "\n\n"
    | where { $in | str trim | is-not-empty }
    | each {|block|
        let lines = ($block | lines)
        let path = ($lines
            | where { $in | str starts-with "worktree " }
            | first
            | str replace "worktree " "")
        let head = ($lines
            | where { $in | str starts-with "HEAD " }
            | first
            | str replace "HEAD " ""
            | str substring 0..7)
        let is_bare = ($lines | any { $in == "bare" })
        let branch_line = ($lines | where { $in | str starts-with "branch " })
        let branch = if ($branch_line | is-empty) {
            if $is_bare { "bare" } else { "detached" }
        } else {
            $branch_line | first | str replace "branch refs/heads/" ""
        }
        { path: $path, branch: $branch, commit: $head }
    }
}

# Completion: branches that currently have a worktree.
def wt-branches [] {
    parse-worktrees
    | where branch not-in ["bare" "detached"]
    | get branch
}

# Completion: local branches without a worktree (candidates for `wt add`).
def available-branches [] {
    let existing = (wt-branches)
    git branch --format '%(refname:short)'
    | lines
    | where { $in not-in $existing }
}

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

# Git worktree management.
#
# Commands:
#   wt add <branch> [-b base]    Create a worktree and cd into it
#   wt remove [branch] [--force] Remove a worktree and delete its local branch
#   wt go <branch>               Jump to an existing worktree
#   wt list                      List all worktrees as a table
export def main []: nothing -> nothing {
    help "wt list"
    print ""
    print "Commands: wt add | wt remove | wt go | wt list"
}

# Create a worktree for the given branch and cd into it.
# If the branch does not exist locally it is created from --base (default: HEAD).
export def --env "wt add" [
    branch: string@available-branches  # Branch name (created from --base if new)
    --base (-b): string                # Start point for new branches (default: HEAD)
]: nothing -> nothing {
    let root = (repo-root)
    let wt_path = ($root | path join ".worktrees" (dir-name $branch))

    if ($wt_path | path exists) {
        error make { msg: $"worktree already exists: ($wt_path)" }
    }

    mkdir ($root | path join ".worktrees")

    let branch_exists = (
        do { git rev-parse --verify --quiet $"refs/heads/($branch)" } | complete
    ).exit_code == 0

    if $branch_exists {
        git worktree add $wt_path $branch
    } else {
        git worktree add -b $branch $wt_path ($base | default "HEAD")
    }

    cd $wt_path
}

# Remove a worktree and delete its local branch.
# When branch is omitted, operates on the current worktree.
export def --env "wt remove" [
    branch?: string@wt-branches  # Branch to remove (default: current worktree)
    --force (-f)                  # Force-remove even if the worktree is dirty
]: nothing -> nothing {
    let root = (repo-root)
    let worktrees = (parse-worktrees)

    let target = if $branch != null { $branch } else {
        let cwd = (pwd)
        let hit = ($worktrees | where path == $cwd)
        if ($hit | is-empty) {
            error make { msg: "not inside a worktree — specify a branch name" }
        }
        ($hit | first).branch
    }

    let main_wt = ($worktrees | first)
    let hit = ($worktrees | where branch == $target)
    if ($hit | is-empty) {
        error make { msg: $"no worktree found for branch: ($target)" }
    }
    let wt_path = ($hit | first).path
    if $wt_path == $main_wt.path {
        error make { msg: "refusing to remove the main worktree" }
    }

    # Step out of the worktree before removing it
    if ((pwd) | str starts-with $wt_path) {
        cd $root
    }

    if $force {
        git worktree remove --force $wt_path
    } else {
        git worktree remove $wt_path
    }

    # Best-effort branch deletion
    let result = (do { git branch -D $target } | complete)
    if $result.exit_code != 0 {
        print $"(ansi yellow_bold)warning:(ansi reset) could not delete branch ($target): ($result.stderr | str trim)"
    }

    print $"Removed worktree and branch: ($target)"
}

# Jump to an existing worktree.
export def --env "wt go" [
    branch: string@wt-branches  # Target worktree branch
]: nothing -> nothing {
    let hit = (parse-worktrees | where branch == $branch)
    if ($hit | is-empty) {
        error make { msg: $"no worktree found for branch: ($branch)" }
    }
    cd ($hit | first).path
}

# List all worktrees (runs `git worktree prune` first).
export def "wt list" []: nothing -> table<path: string, branch: string, commit: string> {
    git worktree prune
    parse-worktrees
}
