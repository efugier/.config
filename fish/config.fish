# 
set -Ux EDITOR kak
set -Ux GIT_EDITOR kak
set -Ux MYTERM alacritty

# Rust
set PATH $HOME/.cargo/bin $PATH

# Go
set GOPATH "$HOME/go:$HOME/code"
set PATH "$PATH:$GOPATH/bin"

eval (starship init fish)
