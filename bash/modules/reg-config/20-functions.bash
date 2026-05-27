#!/usr/bin/env bash

reg-config() {
  local module_dir dotfiles_root dir file
  module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  dotfiles_root="$(cd "$module_dir/../../.." && pwd)"
  dir="$dotfiles_root/config"
  file="$dir/config.list"

  if [[ $# -eq 0 ]]; then
    echo "usage: reg-config <config command>"
    return 1
  fi

  mkdir -p "$dir"

  if [[ ! -f "$file" ]]; then
    {
      echo "#!/usr/bin/env bash"
      echo "set -e"
    } > "$file"
    chmod +x "$file"
  fi

  local line ts
  line="$*"
  ts="$(date '+# [%Y-%m-%d %H:%M]')"

  {
    echo ""
    echo "$ts"
    echo "$line"
  } >> "$file"

  echo "OK registered config: $line"

  if git -C "$dotfiles_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$dotfiles_root" add "config/config.list"
    if git -C "$dotfiles_root" commit -m "reg-config: $line" >/dev/null 2>&1; then
      if git -C "$dotfiles_root" push >/dev/null 2>&1; then
        echo "pushed to origin"
      else
        echo "[WARN] commit feito, mas push falhou"
      fi
    fi
  fi

  echo "running: $line"
  eval "$line"
}

configs() { reg-config "$@"; }
