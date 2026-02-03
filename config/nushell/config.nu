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

# init atuin (shell history)
source ~/.atuin.nu

# init direnv (per-directory env)
source ~/.direnv.nu

# Aliases
alias ls = eza
alias ll = eza -l
alias la = eza -la
alias lt = eza --tree

# Completions
use ~/.config/nushell/git-completions.nu *
use ~/.config/nushell/jj-completions.nu *

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
