#!/usr/bin/env bash

# Compatibilidade com aliases antigos do fluxo diario
alias u="git pull && git add -A && git commit -m 'Update files' && git push; clear"
alias n="git pull; clear"
alias dotpull='git -C "$HOME/.dotfiles" pull --rebase'