# config.nu
#
# Nushell configuration
# Loaded after env.nu and before login.nu
# See https://www.nushell.sh/book/configuration.html

$env.config.show_banner = false

# PATH additions
$env.PATH = ($env.PATH | prepend '~/.bun/bin')

# init zoxide
source ~/.zoxide.nu

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
