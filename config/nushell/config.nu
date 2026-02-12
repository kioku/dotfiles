# config.nu
#
# Nushell configuration
# Loaded after env.nu and before login.nu
# See https://www.nushell.sh/book/configuration.html

$env.config.show_banner = false

# PATH additions
$env.PATH = ($env.PATH
    | prepend '~/.cargo/bin'
    | prepend '~/.bun/bin'
    | prepend '~/.local/bin'  # Claude Code
)

# .NET
$env.DOTNET_ROOT = ($env.HOME | path join '.dotnet')
$env.PATH = ($env.PATH
    | prepend ($env.DOTNET_ROOT | path join 'tools')
    | prepend $env.DOTNET_ROOT
)

# init zoxide
source ~/.zoxide.nu

# zoxide sets __zoxide_hooked as an env var. On newer Nushell builds this can
# break `exec nu` because the inherited string value is re-parsed as a boolean.
# Keep the hook, but avoid exporting the marker to child processes.
if "__zoxide_hooked" in ($env | columns) {
    hide-env __zoxide_hooked
}

# init atuin (shell history)
source ~/.atuin.nu

# init direnv (per-directory env) via PWD hook
$env.config.hooks.env_change.PWD = (
    $env.config.hooks.env_change.PWD? | default [] | append {||
        if (which direnv | is-not-empty) {
            direnv export json | from json | default {} | load-env
        }
    }
)

# Aliases (eza for pretty output, nushell ls for structured data)
alias lss = eza
alias ll = eza -l
alias la = eza -la
alias lt = eza --tree

# Completions / modules.
#
# Use absolute paths rooted at $nu.default-config-dir so imports continue
# to work when config.nu itself is symlinked into /nix/store by Home Manager.
use ($nu.default-config-dir | path join 'git-completions.nu') *
use ($nu.default-config-dir | path join 'jj-completions.nu') *
use ($nu.default-config-dir | path join 'wt.nu') *

# fnm (Node version manager)
if not (which fnm | is-empty) {
    fnm env --json | from json | load-env

    $env.PATH = $env.PATH | prepend ($env.FNM_MULTISHELL_PATH | path join "bin")

    $env.config.hooks.env_change.PWD = (
        $env.config.hooks.env_change.PWD? | append {
            condition: {|| ['.nvmrc' '.node-version'] | any {|el| $el | path exists}}
            code: {|| fnm use}
        }
    )
}
