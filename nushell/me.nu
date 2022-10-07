# Aliases and commands
# ===

# -- unix --

export alias x = xargs -I \args

# normalizes an absolute path, `expand` alone will often leave `/./` in it
export def abspath [] {
      each { |$it| $it | path expand | path parse | path join }
}

# Wrapper around `cd` that manages a `.cd_history` file and allows you to
# chose from it using fzf, or go directly to the matching entry if there
# is only one.
#
# All lines of the history file are supposed to be normalized with
# the `abspath` command and ordered by most recently-visited.
export def-env c [
    query: string = ""
    # existing path, fuzzy path query or special command
    # ...................   - existing path, -, ~ → same as cd
    # ...................   - _ → cross shell equivalent of - (newest entry in history)
    # ...................   - query matching only one history entry → cd to it
    # ...................   - everything else → query for fzf to run on the history
] {
    let history_file = ("~/.cd_history" | abspath)

    # more recently visited directories must be on top for `uniq` to preserve order
    let cd_history = (open $history_file | lines)
    let current_directory = (pwd | str trim | abspath)

    let $target_dir = if (not ($query | is-empty)) && ($query | path exists) {
        $query | abspath
    } else if $query == "-" {
        if "OLDPWD" in (env).name { $env.OLDPWD } else { "" | abspath }
    } else if $query == "~" {
        $query
    } else if $query == "_" {
        $cd_history
        | where $it != $current_directory
        | first
    } else {
        let matching_history = ($cd_history | where $it =~ $query)

        # go directly to the only match
        if ($matching_history | length) == 1 {
            $matching_history | get 0
        } else {
        # select the target in fzf
            $cd_history
            | where ($it != $current_directory) && ($it | path exists)
            | str replace $env.HOME "~"  # nicer on the eyes
            | str collect "\n"
            | fzf $"--query=($query)" --height=40% --layout=reverse --inline-info
        } | str trim | abspath
    }

    # update ~/.cd_history
    $cd_history | prepend $target_dir | uniq | where ($it | path exists) | save $history_file

    cd $target_dir
}

# edit the target of a copy
export def cpe [source: string, --recursive(-r)] {
    let tempfile = "/tmp/.cpmvedit"
    echo $source | save --raw $tempfile
    ^$env.EDITOR $tempfile
    if $recursive {
        cp -r $source (open $tempfile)
    } else {
        cp $source (open $tempfile)
    }
}

# edit the target of a move
export def mve [source: string] {
    let tempfile = "/tmp/.cpmvedit"
    echo $source | save --raw $tempfile
    ^$env.EDITOR $tempfile
     mv $source (open $tempfile)
}

export def rec-sed [query: string, --in_place(-i), --target_dir(-t): string = "", --filter(-f): string = ""] {
    let files = if ($target_dir | str length) > 0 {
        ls $"($target_dir)/**/*" | where type == file | get name
    } else {
        ls **/* | where type == file | get name
    }

    let files = if ($filter | str length) > 0 {
        $files | find --regex $filter
    } else {
        $files
    }

    if $in_place {
        $files | each { |$it| sed -i $query $it }
    } else {
        $files | each { |$it| sed $query $it }
    }
}

# -- git --

export def git-set-personal-credentials [] {
    git config --local user.name "efugier"
    git config --local user.email "mail@emilienfugier.net"
    git config -l | split row "\n" | find "user"
}

export alias gs = git status -sbs
export alias gap = git add -p
export alias gcm = git commit -m
export alias gam = git commit --amend

export def gpf [remote: string = origin] {
    let proceed = if (git branch --show-current | str trim) in ["main", "master"] {
        echo "You currently are on the main/master branch, proceed? [y/n]"
        (input | str trim | str downcase) == "y"
    } else {
        true
    }
    if $proceed {
        git push --force-with-lease=$remote
    } else {
        echo "Aborted."
    }
}

export def gri [offset: int = 3] {
    git rebase -i $"HEAD~($offset)"
}

export def gl [n: int = 13] {
    (
        git log --pretty=%h»¦«%s»¦«%aN»¦«%aD -n $n
        | lines | split column "»¦«" commit message author date
        | upsert date {|d| $d.date | into datetime}
        | upsert author {|d| $d.author | str downcase | split row " " | get 0}
    )
}

export def gd [...args] {
    git diff $args --name-only --relative | xargs bat --color=always --diff
    # let preview = $"git diff ($args) --color=always -- {-1}"
    # git diff $args --name-only | fzf -m --ansi --preview $preview
}

export def fgd [...args] {
    let preview = "bat {} --color=always --diff"
    git diff $args --name-only | fzf --reverse -m --ansi --preview $preview --preview-window up,99%,wrap
}

# Wrapper around `git checkout` using fzf to pick a branch and better
# behavior for `-` (last visited existing branch that isn't the current one).
export def gco [
    --new_branch(-b)  # becomes `git checkout -b $args`
    --list(-l),
    --limit(-o)=20  # how far to go back in checkout history
    ...args,  # will be forwarded to `git checkout $args`
] {
    if $new_branch {
        git checkout -b $args
    } else if $args != [] && $args != ["-"] {
        git checkout $args
    } else {
        let past_branch_names = (
            1..([1 $limit] | math max)
            | each { |$it| do -i { git rev-parse --abbrev-ref $"@{-($it)}" } }
        )

        let current_branch_name = (git branch --show current)

        if $list {
            # display the full, unprocessed hisotry
            $past_branch_names | prepend $current_branch_name
        } else {
            let past_branch_names = (  # remove duplicates, the current branch and deleted ones
                $past_branch_names | uniq | where (not $it =~ "^@") && ($it != $current_branch_name)
            )
            let target_branch = (
                if $args == ["-"] {
                    $past_branch_names | first
                } else {
                    $past_branch_names | str collect | fzf --height=40% --layout=reverse --inline-info
                } | str trim
            )

            if $target_branch != "" {
                git checkout $target_branch
            }
        }
    }
}


# -- python --

export def-env pyenv [command, ...args] {
    let new_env = if $command in ["activate", "deactivate", "rehash", "shell"] {
        if $command == "shell" {
            { PYENV_VERSION_OLD: $env.PYENV_VERSION PYENV_VERSION: $args.0 }
        } else {
            error make { msg: $"`($command)` command is not supported yet" }
        }
    } else {
        ^pyenv $command $args
        {}
    }
    load-env $new_env
}

# use pipenv function made for bash to edit the env
# TODO: add poetry support
export def pshell [] {
    bash "-c" "pipenv run nu"
}
