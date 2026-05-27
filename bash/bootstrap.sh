#!/usr/bin/env bash
# Load all Bash modules in lexical order.

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$DOTFILES_ROOT/modules"

if [[ -d "$MODULES_DIR" ]]; then
  while IFS= read -r -d '' file; do
    # shellcheck disable=SC1090
    source "$file"
  done < <(find "$MODULES_DIR" -type f -name '*.bash' -print0 | sort -z)
fi

unset DOTFILES_ROOT
unset MODULES_DIR
