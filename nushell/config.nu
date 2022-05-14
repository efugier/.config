# Nushell Config File

module completions {
  # Custom completions for external commands (those outside of Nushell)
  # Each completions has two parts: the form of the external command, including its flags and parameters
  # and a helper command that knows how to complete values for those flags and parameters
  #
  # This is a simplified version of completions for git branches and git remotes
  def "nu-complete git branches" [] {
    ^git branch | lines | each { |line| $line | str replace '[\*\+] ' '' | str trim }
  }

  def "nu-complete git remotes" [] {
    ^git remote | lines | each { |line| $line | str trim }
  }

  export extern "git checkout" [
    branch?: string@"nu-complete git branches" # name of the branch to checkout
    -b: string                                 # create and checkout a new branch
    -B: string                                 # create/reset and checkout a branch
    -l                                         # create reflog for new branch
    --guess                                    # second guess 'git checkout <no-such-branch>' (default)
    --overlay                                  # use overlay mode (default)
    --quiet(-q)                                # suppress progress reporting
    --recurse-submodules: string               # control recursive updating of submodules
    --progress                                 # force progress reporting
    --merge(-m)                                # perform a 3-way merge with the new branch
    --conflict: string                         # conflict style (merge or diff3)
    --detach(-d)                               # detach HEAD at named commit
    --track(-t)                                # set upstream info for new branch
    --force(-f)                                # force checkout (throw away local modifications)
    --orphan: string                           # new unparented branch
    --overwrite-ignore                         # update ignored files (default)
    --ignore-other-worktrees                   # do not check if another worktree is holding the given ref
    --ours(-2)                                 # checkout our version for unmerged files
    --theirs(-3)                               # checkout their version for unmerged files
    --patch(-p)                                # select hunks interactively
    --ignore-skip-worktree-bits                # do not limit pathspecs to sparse entries only
    --pathspec-from-file: string               # read pathspec from file
  ]

  export extern "git push" [
    remote?: string@"nu-complete git remotes", # the name of the remote
    refspec?: string@"nu-complete git branches"# the branch / refspec
    --verbose(-v)                              # be more verbose
    --quiet(-q)                                # be more quiet
    --repo: string                             # repository
    --all                                      # push all refs
    --mirror                                   # mirror all refs
    --delete(-d)                               # delete refs
    --tags                                     # push tags (can't be used with --all or --mirror)
    --dry-run(-n)                              # dry run
    --porcelain                                # machine-readable output
    --force(-f)                                # force updates
    --force-with-lease: string                 # require old value of ref to be at this value
    --recurse-submodules: string               # control recursive pushing of submodules
    --thin                                     # use thin pack
    --receive-pack: string                     # receive pack program
    --exec: string                             # receive pack program
    --set-upstream(-u)                         # set upstream for git pull/status
    --progress                                 # force progress reporting
    --prune                                    # prune locally removed refs
    --no-verify                                # bypass pre-push hook
    --follow-tags                              # push missing but relevant tags
    --signed: string                           # GPG sign the push
    --atomic                                   # request atomic transaction on remote side
    --push-option(-o): string                  # option to transmit
    --ipv4(-4)                                 # use IPv4 addresses only
    --ipv6(-6)                                 # use IPv6 addresses only
  ]
}

# Get just the extern definitions without the custom completion commands
use completions *

# for more information on themes see
# https://www.nushell.sh/book/coloring_and_theming.html
let default_theme = {
    # color for nushell primitives
    separator: white
    leading_trailing_space_bg: { attr: n } # no fg, no bg, attr none effectively turns this off
    header: green_bold
    empty: blue
    bool: white
    int: white
    filesize: white
    duration: white
    date: white
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    cellpath: white
    row_index: green_bold
    record: white
    list: white
    block: white
    hints: dark_gray

    # shapes are used to change the cli syntax highlighting
    shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: b}
    shape_binary: purple_bold
    shape_bool: light_cyan
    shape_int: purple_bold
    shape_float: purple_bold
    shape_range: yellow_bold
    shape_internalcall: cyan_bold
    shape_external: cyan
    shape_externalarg: green_bold
    shape_literal: blue
    shape_operator: yellow
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_datetime: cyan_bold
    shape_list: cyan_bold
    shape_table: blue_bold
    shape_record: cyan_bold
    shape_block: blue_bold
    shape_filepath: cyan
    shape_globpattern: cyan_bold
    shape_variable: purple
    shape_flag: blue_bold
    shape_custom: green
    shape_nothing: light_cyan
}

# The default config record. This is where much of your global configuration is setup.
let $config = {
  filesize_metric: false
  table_mode: rounded # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
  use_ls_colors: true
  rm_always_trash: false
  color_config: $default_theme
  use_grid_icons: true
  footer_mode: "25" # always, never, number_of_rows, auto
  quick_completions: true  # set this to false to prevent auto-selecting completions when only one remains
  partial_completions: true  # set this to false to prevent partial filling of the prompt
  animate_prompt: false # redraw the prompt every second
  float_precision: 2
  use_ansi_coloring: true
  filesize_format: "auto" # b, kb, kib, mb, mib, gb, gib, tb, tib, pb, pib, eb, eib, zb, zib, auto
  edit_mode: emacs # emacs, vi
  max_history_size: 10000 # Session has to be reloaded for this to take effect
  sync_history_on_enter: true # Enable to share the history between multiple sessions, else you have to close the session to persist history to file
  menus: [
      # Configuration for default nushell menus
      # Note the lack of souce parameter
      {
        name: completion_menu
        only_buffer_difference: false
        marker: "| "
        type: {
            layout: columnar
            columns: 4
            col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
            col_padding: 2
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
      }
      {
        name: history_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: list
            page_size: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
      }
      {
        name: help_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: description
            columns: 4
            col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
            col_padding: 2
            selection_rows: 4
            description_rows: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
      }
      # Example of extra menus created using a nushell source
      # Use the source field to create a list of records that populates
      # the menu
      {
        name: commands_menu
        only_buffer_difference: false
        marker: "# "
        type: {
            layout: columnar
            columns: 4
            col_width: 20
            col_padding: 2
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
        source: { |buffer, position|
            $nu.scope.commands
            | where command =~ $buffer
            | each { |it| {value: $it.command description: $it.usage} }
        }
      }
      {
        name: vars_menu
        only_buffer_difference: true
        marker: "# "
        type: {
            layout: list
            page_size: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
        source: { |buffer, position|
            $nu.scope.vars
            | where name =~ $buffer
            | sort-by name
            | each { |it| {value: $it.name description: $it.type} }
        }
      }
      {
        name: commands_with_description
        only_buffer_difference: true
        marker: "# "
        type: {
            layout: description
            columns: 4
            col_width: 20
            col_padding: 2
            selection_rows: 4
            description_rows: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
        source: { |buffer, position|
            $nu.scope.commands
            | where command =~ $buffer
            | each { |it| {value: $it.command description: $it.usage} }
        }
      }
  ]
  keybindings: [
    {
      name: completion_menu
      modifier: none
      keycode: tab
      mode: emacs # Options: emacs vi_normal vi_insert
      event: {
        until: [
          { send: menu name: completion_menu }
          { send: menunext }
        ]
      }
    }
    {
      name: completion_previous
      modifier: shift
      keycode: backtab
      mode: [emacs, vi_normal, vi_insert] # Note: You can add the same keybinding to all modes by using a list
      event: { send: menuprevious }
    }
    {
      name: history_menu
      modifier: control
      keycode: char_x
      mode: emacs
      event: {
        until: [
          { send: menu name: history_menu }
          { send: menupagenext }
        ]
      }
    }
    {
      name: history_previous
      modifier: control
      keycode: char_z
      mode: emacs
      event: {
        until: [
          { send: menupageprevious }
          { edit: undo }
        ]
      }
    }
    # Keybindings used to trigger the user defined menus
    {
      name: commands_menu
      modifier: control
      keycode: char_t
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menu name: commands_menu }
    }
    {
      name: vars_menu
      modifier: control
      keycode: char_y
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menu name: vars_menu }
    }
    {
      name: commands_with_description
      modifier: control
      keycode: char_u
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menu name: commands_with_description }
    }
  ]
}
# -- PROMPT --

let-env STARSHIP_SHELL = "nu"

def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

def create_right_prompt [] {
    let time_segment = ([
        (date now | date format '%d/%m - %H:%M:%S')
    ] | str collect)

    $time_segment
}

# Use nushell functions to define your right and left prompt
let-env PROMPT_COMMAND = { create_left_prompt }
let-env PROMPT_COMMAND_RIGHT = { "" }

# The prompt indicators are environmental variables that represent
# the state of the prompt
let-env PROMPT_INDICATOR = ""
let-env PROMPT_INDICATOR_VI_INSERT = ": "
let-env PROMPT_INDICATOR_VI_NORMAL = "〉"
let-env PROMPT_MULTILINE_INDICATOR = "::: "

# -- PATH --

# system
let-env EDITOR = "hx"
let-env GIT_EDITOR = "hx"

let-env PATH = ($env.PATH | append $"($env.HOME)/.local/bin")

# homebrew
let-env PATH = ($env.PATH | append "/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin")
let-env HOMEBREW_PREFIX = "/home/linuxbrew/.linuxbrew"
let-env HOMEBREW_CELLAR = "/home/linuxbrew/.linuxbrew/Cellar"
let-env HOMEBREW_REPOSITORY = "/home/linuxbrew/.linuxbrew/Homebrew"
let-env MANPATH = "/home/linuxbrew/.linuxbrew/share/man"
let-env INFOPATH = "/home/linuxbrew/.linuxbrew/share/info"

# Helix
let-env HELIX_RUNTIME = $"($env.HOME)/.config/helix/runtime"

# Rust
let-env PATH = ($env.PATH | append $"($env.HOME)/.cargo/bin")

# Go
let-env GOPATH = $"($env.HOME)/go:$env.HOME/code"
let-env PATH = ($env.PATH | append "$GOPATH/bin")
let-env PATH = ($env.PATH | append "/usr/local/go/bin")

# Pyenv
let-env PATH = ($env.PATH | append $"($env.HOME)/.pyenv/bin")
let-env PATH = ($env.PATH | append $"($env.HOME)/.pyenv/shims")
# replicate pyenv init - | source
let-env PYENV_VERSION = ""
let-env PYENV_VERSION_OLD = ""
let-env PYENV_SHELL = "nu"
#source '/home/emilien.fugier/.pyenv/libexec/../completions/pyenv.bash'

def-env pyenv [command, ...args] {
    let new-env = if $command in ["activate", "deactivate", "rehash", "shell"] {
        if $command == "shell" {
            { PYENV_VERSION_OLD: $env.PYENV_VERSION PYENV_VERSION: $args.0 }
        }
    } else {
        ^pyenv $command $args
        {}
    }
    load-env $new-env
}

# Pipenv
def pshell [] {
    fish "-c" "pipenv run nu"
}
let-env PIPENV_PYTHON = $"($env.HOME)/.pyenv/shims/python"
let-env PIPENV_VENV_IN_PROJECT = 1 # optional but recommended


# -- Aliases and commands --

alias x = xargs

def abspath [] {
      each { |$it| $it | path expand | path parse | path join }
}

# Wrapper around `cd` that manages a `.cd_history` file and
# allows you to chose from it using fzf.
# All entries in the history are supposed to be normalized with the `abspath` command
# and ordered by most recent-first.
def-env c [
    query: string = ""
    # path, fzf query or special command
    # ...................   - existing path, -, ~ → same as cd
    # ...................   - _ → cross shell equivalent of - (newest entry in history)
    # ...................   - everything else → query for fzf
] {
    let history_file = ("~/.cd_history" | abspath)

    # nore recent must be on top for `uniq` preserve order
    let cd_history = (open $history_file | lines)
    let current_directory = (pwd | str trim | abspath)

    let $target_dir = if ($query | path exists) {
        let query = ($query | abspath)
        $cd_history | prepend $query | uniq | save $history_file
        $query
    } else if ($query in ["~"]) {
        $query
    } else if $query == "-" {
        # for some reason returning "-" above doesn't work
        if "OLDPWD" in (env).name { $env.OLDPWD } else { "" }
    } else if $query == "_" {
        $cd_history
        | where $it != $current_directory
        | first
    } else {
        let target_dir = (
            $cd_history
            | where $it != $current_directory
            | str replace $env.HOME "~"  # nicer on the eyes
            | str collect "\n"
            | fzf $"--query=($query)" | str trim | abspath
        )
        if $target_dir != "" && ($target_dir | path exists) {
            $cd_history | prepend $target_dir | uniq | save $history_file
        }
        $target_dir
    }
    cd $target_dir
}

# git

def git-personal-credentials [] {
    git config --local user.name "efugier"
    git config --local user.email "mail@emilienfugier.net"
}

alias gs = git status
alias gap = git add -p
alias gcm = git commit -m
alias gam = git commit --amend
alias gdiff = git diff

def gpf [remote: string = origin] {
    git push --force-with-lease=$remote
}

def gri [offset: int = 3] {
    git rebase -i $"HEAD~($offset)"
}

def gl [n: int = 13] {
    (
        git log --pretty=%h»¦«%s»¦«%aN»¦«%aD -n $n
        | lines | split column "»¦«" commit message author date
        | upsert date {|d| $d.date | into datetime}
        | upsert author {|d| $d.author | str downcase | split row " " | get 0}
    )
}

# A slightly improved `git checkout` with fzf to pick a branch and better
# behavior for `-` (last visited existing branch that isn't the current one).
def gco [
    --list(-l),
    --offset(-o)=10  # how far to go back in checkout  history
    ...args,  # will be forwarded to `git checkout $args`
] {
    if $args != [] && $args != ["-"] {
        git checkout $args
    } else {
        let past_branch_names = (
            for $i in 1..([1 $offset] | math max) {
                do -i {  # suppress stderr
                    git rev-parse --abbrev-ref $"@{-($i)}"
                }
            }
        )

        let current_branch_name = (git branch --show current)

        if $list {
            $past_branch_names | prepend $current_branch_name
        } else {
            let past_branch_names = (  # remove duplicates, the current branch and deleted ones
                $past_branch_names | uniq | where (not $it =~ "^@") && ($it != $current_branch_name)
            )
            let target_branch = (
                if $args == ["-"] {
                    $past_branch_names | first
                } else {
                    $past_branch_names | str collect | fzf
                } | str trim
            )
            git checkout $target_branch
        }
    }
}



# -- use custom files --

# use XXXXX/me.nu *
# use XXXXX/work.nu *
