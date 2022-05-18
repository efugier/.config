# Aliases and commands
# ===

# -- unix --

export alias x = xargs -I \args

# normalizes an absolute path, `expand` alone will often leave `/./` in it
export def abspath [] {
      each { |$it| $it | path expand | path parse | path join }
}

# Wrapper around `cd` that manages a `.cd_history` file and
# allows you to chose from it using fzf.
# All entries in the history are supposed to be normalized with the `abspath` command
# and ordered by most recent-first.
export def-env c [
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
        # save the new history
        $cd_history | prepend $query | uniq | where ($it | path exists) | save $history_file
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
            | where ($it != $current_directory) && ($it | path exists)
            | str replace $env.HOME "~"  # nicer on the eyes
            | str collect "\n"
            | fzf $"--query=($query)" | str trim | abspath
        )
        if $target_dir != "" && ($target_dir | path exists) {
            # save the new history
            $cd_history | prepend $target_dir | uniq | save $history_file
        }
        $target_dir
    }
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

# -- git --

export def git-set-personal-credentials [] {
    git config --local user.name "efugier"
    git config --local user.email "mail@emilienfugier.net"
    git config -l | split row "\n" | find "user"
}

export alias gs = git status
export alias gap = git add -p
export alias gcm = git commit -m
export alias gam = git commit --amend
export alias gdiff = git diff

export def gpf [remote: string = origin] {
    git push --force-with-lease=$remote
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

# Wrapper around `git checkout` using fzf to pick a branch and better
# behavior for `-` (last visited existing branch that isn't the current one).
export def gco [
    --new_branch(-b)  # becomes `git checkout -b $args`
    --list(-l),
    --limit(-o)=10  # how far to go back in checkout history
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
                    $past_branch_names | str collect | fzf
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
    let new-env = if $command in ["activate", "deactivate", "rehash", "shell"] {
        if $command == "shell" {
            { PYENV_VERSION_OLD: $env.PYENV_VERSION PYENV_VERSION: $args.0 }
        } else {
            error make { msg: $"`($command)` command is not supported yet" }
        }
    } else {
        ^pyenv $command $args
        {}
    }
    load-env $new-env
}

# use pipenv function made for bash to edit the env
# TODO: add poetry support
export def pshell [] {
    bash "-c" "pipenv run nu"
}


# -- nushell --

export alias from-text = split row "\n"
export alias to-text = str collect "\n"
