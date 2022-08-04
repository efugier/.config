. ~/.config/fish/abbreviations.fish
. ~/.config/fish/_work_abbreviations.fish

. ~/.config/fish/aliases.fish
. ~/.config/fish/_work_aliases.fish

# system
set -Ux EDITOR hx
set -Ux GIT_EDITOR hx
set -Ux MYTERM alacritty

fish_add_path $HOME/.local/bin

# Helix
set -Ux HELIX_RUNTIME "$HOME/.config/helix/runtime"

# Rust
fish_add_path $HOME/.cargo/bin

# Go
set -Ux GOPATH "$HOME/go:$HOME/code"
fish_add_path "$GOPATH/bin"
fish_add_path "/usr/local/go/bin"

# Pyenv
fish_add_path $HOME/.pyenv/bin
pyenv init --path | source
pyenv init - | source
set -x PIPENV_PYTHON "$HOME/.pyenv/shims/python"
set -x PIPENV_VENV_IN_PROJECT 1 # optional but recommended

eval (starship init fish)
