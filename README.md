A worflow based on:

- [nushell](https://www.nushell.sh)
- [helix](https://helix-editor.com)
- [bat](https://github.com/sharkdp/bat)
- [cargo](https://github.com/rust-lang/cargo)
- [alacritty](https://github.com/alacritty/alacritty)
- [kakoune](https://github.com/mawww/kakoune)
- [kak-lsp](https://github.com/kak-lsp/kak-lsp)
- [fish](https://fishshell.com/)
- [starship](https://starship.rs/)


Coding stuff is assumed to be in `~/code`.
Open source repos are assumed to be in `~/from-source`.

`bin` contains cool exectuables that can be tied to shorcuts through the desktop environment's settings.


# Installing everything

- install apps through `brew` if available
- never use system python, ever; use `pyenv`

```
mkdir code
mkdir from-source

# Git
sudo apt install git git-lfs

# Building stuff
sudo apt install build-essential cmake openssl libfontconfig libfontconfig1-dev apt pkg-config libssl-dev libxcb-composite0-dev libx11-dev

# Brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /home/emilien.fugier/.profile
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/emilien.fugier/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install gcc

# Tooling
sudo apt install xclip

curl https://sh.rustup.rs -sSf | sh

cargo install alacritty
cargo install nu --features=extra
cargo install mdbook

# Installing the config
git clone https://github.com/efugier/.config.git /tmp/.config
cp -r /tmp/.config/* ~/.config/

echo "use ~/.config/nushell/me.nu *; use ~/.config/nushell/_work.nu *" >> .config/nushell/config.nu
touch ~/.config/nushell/_work.nu

brew update
brew install starship fzf helix ripgrep bat pyenv jq kubectx derailed/k9s/k9s fd httpie

hx --grammar fetch && hx --grammar build

sudo echo $(which nu) >> /etc/shells
sudo chsh -s "$(which nu)" "${USER}"
```

Log out, log in... and _voilà_!
