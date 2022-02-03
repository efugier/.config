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

eval (starship init fish)
