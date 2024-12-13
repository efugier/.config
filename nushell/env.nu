# Nushell Environment Config File
#
# version = 0.80.1

# -- PROMPT --

$env.STARSHIP_SHELL = "nu"

def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

def create_right_prompt [] {
    let time_segment = ([
        (date now | format date '%d/%m - %H:%M:%S')
    ] | str join)

    $time_segment
}


# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')

# -- PATH --

# -- system --
$env.EDITOR = "hx"
$env.GIT_EDITOR = "hx"
$env.PKG_CONFIG = "/usr/bin/pkg-config"

$env.PATH = ($env.PATH | append $"($env.HOME)/.config/bin")

#  -- homebrew --
$env.PATH = ($env.PATH | append "/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin")
$env.HOMEBREW_PREFIX = "/home/linuxbrew/.linuxbrew"
$env.HOMEBREW_CELLAR = "/home/linuxbrew/.linuxbrew/Cellar"
$env.HOMEBREW_REPOSITORY = "/home/linuxbrew/.linuxbrew/Homebrew"
$env.MANPATH = "/home/linuxbrew/.linuxbrew/share/man"
$env.INFOPATH = "/home/linuxbrew/.linuxbrew/share/info"

# -- docker --
$env.GPG_TTY = $"(tty)"

# -- helix --
$env.HELIX_RUNTIME = $"($env.HOME)/.config/helix/runtime"

# -- rust --
$env.PATH = ($env.PATH | append $"($env.HOME)/.cargo/bin")

# -- go --
$env.GOPATH = $"($env.HOME)/go:($env.HOME)/code"
$env.PATH = ($env.PATH | append $"($env.HOME)/go/bin")
$env.PATH = ($env.PATH | append "/usr/local/go/bin")

# -- pyenv --

$env.PATH = ($env.PATH | prepend $"($env.HOME)/.pyenv/bin")
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.pyenv/shims")
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.adv/bin")

# replicate pyenv init - | source
#TODO: replicate source '/home/XXXX/.pyenv/libexec/../completions/pyenv.bash'
$env.PYENV_VERSION = ""
$env.PYENV_VERSION_OLD = ""
$env.PYENV_SHELL = "nu"

# -- pipenv --

$env.PIPENV_PYTHON = $"($env.HOME)/.pyenv/shims/python"
$env.PIPENV_VENV_IN_PROJECT = 1 # optional but recommended

# -- npm --

$env.PATH = ($env.PATH | append $"($env.HOME)/.npm-global/bin")
