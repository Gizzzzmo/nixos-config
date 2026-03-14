# Nushell Config File
#
# version = "0.99.1"

# For more information on defining custom themes, see
# https://www.nushell.sh/book/coloring_and_theming.html
# And here is the theme collection
# https://github.com/nushell/nu_scripts/tree/main/themes
def --env ..g [] {
    let git_dir = git rev-parse --show-toplevel
    cd $git_dir
}

$env.config.keybindings ++= [
    {
        name: complete
        modifier: control
        keycode: char_f
        mode: [emacs, vi_insert, vi_normal]
        event: { send: historyhintcomplete }
    }
    {
        name: escape
        modifier: control
        keycode: char_u
        mode: [vi_insert, emacs]
        event: { edit: clear }
    }
]

$env.PATH ++=  ["C:/Program Files/git/bin"]
$env.TERM = "xterm-256color"

$env.config.cursor_shape = {
    vi_insert: line
    vi_normal: block
}

$env.config.show_banner = false
$env.config.buffer_editor = ["vim"]
$env.config.edit_mode = 'vi'
$env.EDITOR = "vim"
alias ... = cd ../..

alias ll = eza -lg --git;
alias lla = eza -lga --git;
alias la = eza -a;
alias lt = eza -s modified -lg;
alias lta = eza -s modified -lga --git;

alias cat = bat

source ~/AppData/Roaming/nushell/zoxide.nu
source ~/AppData/Roaming/nushell/completions/pixi.nu
source ~/AppData/Roaming/nushell/completions/git.nu
source ~/AppData/Roaming/nushell/completions/make.nu
