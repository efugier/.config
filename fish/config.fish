# system
set -Ux EDITOR hx
set -Ux GIT_EDITOR hx
set -Ux MYTERM alacritty


# Helix
set -Ux HELIX_RUNTIME "$HOME/.config/helix/runtime"

# Rust
set -Ux PATH $HOME/.cargo/bin $PATH

# Go
set -Ux GOPATH "$HOME/go:$HOME/code"
set -Ux PATH "$PATH:$GOPATH/bin"
set -Ux PATH "$PATH:/usr/local/go/bin"

# Pyenv
set -x PATH $HOME/.pyenv/bin $PATH
pyenv init --path | source
pyenv init - | source
set -x PIPENV_PYTHON "$HOME/.pyenv/shims/python"
set -x PIPENV_VENV_IN_PROJECT 1 # optional but recommended

# httpie
alias https='http --default-scheme=https'

eval (starship init fish)
