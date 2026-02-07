# env.nu
#
# Nushell environment configuration
# Loaded before config.nu and login.nu
# See https://www.nushell.sh/book/configuration.html

$env.config.buffer_editor = "nvim"
$env.config.edit_mode = "vi"
$env.config.show_banner = false

# NixOS exports environment.variables into /etc/set-environment for POSIX shells.
# Nushell does not source it automatically, so import simple export KEY="VALUE"
# pairs without overriding variables that are already present.
let nix_set_environment = "/etc/set-environment"
if ($nix_set_environment | path exists) {
    let existing_env_keys = ($env | columns)
    let nix_env = (
        open $nix_set_environment
        | lines
        | where {|line| $line | str starts-with "export "}
        | parse --regex '^export\s+(?<key>[A-Za-z_][A-Za-z0-9_]*)="(?<value>(?:\\.|[^"])*)"$'
        | where {|row| not ($existing_env_keys | any {|k| $k == $row.key})}
        | reduce -f {} {|row, acc| $acc | upsert $row.key $row.value}
    )

    if (($nix_env | columns | length) > 0) {
        load-env $nix_env
    }
}

# Initialize zoxide
zoxide init nushell | save -f ~/.zoxide.nu

# Initialize atuin (shell history)
if (which atuin | is-not-empty) {
    atuin init nu | save -f ~/.atuin.nu
} else {
    "" | save -f ~/.atuin.nu
}

# Initialize direnv (per-directory env) - manual hook since direnv doesn't support nu natively
"" | save -f ~/.direnv.nu

# Initialize starship prompt
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# Source secrets (must exist, can be empty)
source ~/.secrets.nu
