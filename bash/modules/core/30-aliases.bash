#!/usr/bin/env bash

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'

unalias reloadsh 2>/dev/null || true
unalias bash 2>/dev/null || true

function reloadsh {
  local cwd="$PWD"
  # shellcheck disable=SC1090
  source ~/.bashrc
  cd "$cwd" || return
}
