#!/usr/bin/env bash

export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

if declare -f path_prepend >/dev/null 2>&1; then
  path_prepend "$PYENV_ROOT/bin"
elif [[ -d "$PYENV_ROOT/bin" ]] && [[ ":$PATH:" != *":$PYENV_ROOT/bin:"* ]]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
fi

if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi
