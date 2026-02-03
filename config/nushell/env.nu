# env.nu
#
# Nushell environment configuration
# Loaded before config.nu and login.nu
# See https://www.nushell.sh/book/configuration.html

$env.config.buffer_editor = "nvim"
$env.config.edit_mode = "vi"
$env.config.show_banner = false

# Initialize zoxide
zoxide init nushell | save -f ~/.zoxide.nu

# Initialize atuin (shell history)
if (which atuin | is-not-empty) {
    atuin init nu | save -f ~/.atuin.nu
} else {
    "" | save -f ~/.atuin.nu
}

# Initialize direnv (per-directory env)
if (which direnv | is-not-empty) {
    direnv hook nu | save -f ~/.direnv.nu
} else {
    "" | save -f ~/.direnv.nu
}

# Initialize starship prompt
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# Source secrets (must exist, can be empty)
source ~/.secrets.nu
