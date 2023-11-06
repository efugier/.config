# Nushell Environment Config File
#
# version = 0.80.1

# -- PROMPT --

let-env STARSHIP_SHELL = "nu"

def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

def create_right_prompt [] {
    let time_segment = ([
        (date now | date format '%d/%m - %H:%M:%S')
    ] | str join)

    $time_segment
}


# Use nushell functions to define your right and left prompt
let-env PROMPT_COMMAND = {|| create_left_prompt }
let-env PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
let-env PROMPT_INDICATOR = {|| "> " }
let-env PROMPT_INDICATOR_VI_INSERT = {|| ": " }
let-env PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
let-env PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
let-env ENV_CONVERSIONS = {
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
let-env NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
let-env NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# let-env PATH = ($env.PATH | split row (char esep) | prepend '/some/path')

# -- PATH --

# -- system --
let-env EDITOR = "nvim"
let-env GIT_EDITOR = "nvim"

let-env PATH = ($env.PATH | append $"($env.HOME)/.config/bin")

#  -- homebrew --
let-env PATH = ($env.PATH | append "/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin")
let-env HOMEBREW_PREFIX = "/home/linuxbrew/.linuxbrew"
let-env HOMEBREW_CELLAR = "/home/linuxbrew/.linuxbrew/Cellar"
let-env HOMEBREW_REPOSITORY = "/home/linuxbrew/.linuxbrew/Homebrew"
let-env MANPATH = "/home/linuxbrew/.linuxbrew/share/man"
let-env INFOPATH = "/home/linuxbrew/.linuxbrew/share/info"

# -- docker --
let-env GPG_TTY = $"(tty)"

# -- helix --
let-env HELIX_RUNTIME = $"($env.HOME)/.config/helix/runtime"

# -- rust --
let-env PATH = ($env.PATH | append $"($env.HOME)/.cargo/bin")

# -- go --
let-env GOPATH = $"($env.HOME)/go:($env.HOME)/code"
let-env PATH = ($env.PATH | append $"($env.HOME)/go/bin")
let-env PATH = ($env.PATH | append "/usr/local/go/bin")

# -- pyenv --

let-env PATH = ($env.PATH | prepend $"($env.HOME)/.pyenv/bin")
let-env PATH = ($env.PATH | prepend $"($env.HOME)/.pyenv/shims")
let-env PATH = ($env.PATH | prepend $"($env.HOME)/.adv/bin")

# replicate pyenv init - | source
#TODO: replicate source '/home/XXXX/.pyenv/libexec/../completions/pyenv.bash'
let-env PYENV_VERSION = ""
let-env PYENV_VERSION_OLD = ""
let-env PYENV_SHELL = "nu"

# -- pipenv --

let-env PIPENV_PYTHON = $"($env.HOME)/.pyenv/shims/python"
let-env PIPENV_VENV_IN_PROJECT = 1 # optional but recommended

# -- npm --

let-env PATH = ($env.PATH | append $"($env.HOME)/.npm-global/bin")
