# Git completions with alias awareness.
#
# Design:
# - Completes `git <subcommand>` from both built-in git commands and local
#   aliases from `git config`.
# - Adds targeted extern signatures for common commands + aliases so branch/
#   ref/path completions still work for aliases like `git co`, `git aa`, etc.

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def git-alias-table [] {
    let raw = (do { ^git config --get-regexp '^alias\\.' } | complete)
    if $raw.exit_code != 0 {
        return []
    }

    $raw.stdout
    | lines
    | where {|line| $line | str trim | is-not-empty }
    | parse --regex '^alias\.(?<name>\S+)\s+(?<expansion>.+)$'
}

def git-builtin-subcommands [] {
    let raw = (do { ^git help -a } | complete)
    if $raw.exit_code != 0 {
        return []
    }

    $raw.stdout
    | lines
    | parse --regex '^\s{3}(?<cmd>[a-z0-9][a-z0-9-]*)\s+.+$'
    | get cmd
    | uniq
    | sort
}

def "nu-complete git subcommands" [] {
    let builtins = (git-builtin-subcommands)
    let alias_rows = (git-alias-table)
    let aliases = if ($alias_rows | is-empty) {
        []
    } else {
        $alias_rows | get name
    }

    [$builtins $aliases]
    | flatten
    | uniq
    | sort
}

def "nu-complete git local branches" [] {
    let raw = (do { ^git for-each-ref --format='%(refname:short)' refs/heads } | complete)
    if $raw.exit_code != 0 {
        return []
    }

    $raw.stdout
    | lines
    | where {|line| $line | str trim | is-not-empty }
    | sort
}

def "nu-complete git remotes" [] {
    let raw = (do { ^git remote } | complete)
    if $raw.exit_code != 0 {
        return []
    }

    $raw.stdout
    | lines
    | where {|line| $line | str trim | is-not-empty }
    | sort
}

def "nu-complete git refs" [] {
    let raw = (
        do { ^git for-each-ref --format='%(refname:short)' refs/heads refs/remotes refs/tags }
        | complete
    )
    if $raw.exit_code != 0 {
        return ["HEAD" "ORIG_HEAD"]
    }

    [["HEAD" "ORIG_HEAD"] ($raw.stdout
        | lines
        | where {|line| $line | str trim | is-not-empty })]
    | flatten
    | uniq
    | sort
}

# ---------------------------------------------------------------------------
# Extern signatures
# ---------------------------------------------------------------------------

# Generic git signature: complete first subcommand (including aliases).
export extern git [
    subcommand?: string@"nu-complete git subcommands"
    ...args: string
]

# Common porcelain commands
export extern "git add" [
    ...pathspecs: path
]

export extern "git branch" [
    branch?: string@"nu-complete git local branches"
]

export extern "git checkout" [
    ref?: string@"nu-complete git refs"
    ...paths: path
]

export extern "git cherry-pick" [
    revision?: string@"nu-complete git refs"
]

export extern "git fetch" [
    remote?: string@"nu-complete git remotes"
]

export extern "git pull" [
    remote?: string@"nu-complete git remotes"
    branch?: string@"nu-complete git local branches"
]

export extern "git push" [
    remote?: string@"nu-complete git remotes"
    branch?: string@"nu-complete git local branches"
]

export extern "git rebase" [
    upstream?: string@"nu-complete git refs"
]

export extern "git restore" [
    ...pathspecs: path
]

export extern "git rm" [
    ...pathspecs: path
]

export extern "git switch" [
    branch?: string@"nu-complete git local branches"
]

# Alias-aware signatures (matching aliases in gitconfig)
export extern "git aa" [
    ...pathspecs: path
]

export extern "git ap" [
    ...pathspecs: path
]

export extern "git br" [
    branch?: string@"nu-complete git local branches"
]

export extern "git co" [
    ref?: string@"nu-complete git refs"
    ...paths: path
]

export extern "git cp" [
    revision?: string@"nu-complete git refs"
]

export extern "git delete-branch" [
    branch: string@"nu-complete git local branches"
]
