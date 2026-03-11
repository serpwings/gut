#!/usr/bin/env bash
#
# Bash completion for gut

_gut_completion() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    local commands="init status save undo sync branch switch integrate replay sub big rescue history stash alias compare tag protect snapshot whoops blame stats age pr patch bisect log git --help -h --version -v"

    case "${prev}" in
        branch)
            COMPREPLY=( $(compgen -W "list new delete rename" -- "$cur") )
            return 0
            ;;
        sub)
            COMPREPLY=( $(compgen -W "list add update sync remove" -- "$cur") )
            return 0
            ;;
        big)
            COMPREPLY=( $(compgen -W "scan track setup status" -- "$cur") )
            return 0
            ;;
        rescue)
            COMPREPLY=( $(compgen -W "health detached conflicts lost rebase stash init" -- "$cur") )
            return 0
            ;;
        stash)
            COMPREPLY=( $(compgen -W "save pop list drop show apply clear" -- "$cur") )
            return 0
            ;;
        alias)
            COMPREPLY=( $(compgen -W "list add remove run" -- "$cur") )
            return 0
            ;;
        tag)
            COMPREPLY=( $(compgen -W "list create push delete latest" -- "$cur") )
            return 0
            ;;
        protect)
            COMPREPLY=( $(compgen -W "status add remove" -- "$cur") )
            return 0
            ;;
        patch)
            COMPREPLY=( $(compgen -W "create apply" -- "$cur") )
            return 0
            ;;
        bisect)
            COMPREPLY=( $(compgen -W "start good bad skip abort log" -- "$cur") )
            return 0
            ;;
        switch|integrate|compare)
            if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
                local branches=$(git branch --format='%(refname:short)' 2>/dev/null)
                COMPREPLY=( $(compgen -W "$branches" -- "$cur") )
            fi
            return 0
            ;;
        blame|save|undo)
            COMPREPLY=( $(compgen -f -- "$cur") )
            return 0
            ;;
    esac

    # Top-level completion
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "${commands}" -- "$cur") )
        return 0
    fi
}

complete -F _gut_completion gut
