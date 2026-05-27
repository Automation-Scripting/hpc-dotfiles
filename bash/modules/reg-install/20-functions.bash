#!/usr/bin/env bash

reg-install() {
  local module_dir dotfiles_root dir file
  module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  dotfiles_root="$(cd "$module_dir/../../.." && pwd)"
  dir="$dotfiles_root/bash/install"
  file="$dir/installs.list"

  if [[ $# -eq 0 ]]; then
    echo "usage: reg-install <install command>"
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

  echo "OK registered install: $line"

  if git -C "$dotfiles_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$dotfiles_root" add "bash/install/installs.list"
    git -C "$dotfiles_root" commit -m "reg-install: $line" >/dev/null 2>&1 || true
  fi

  echo "running: $line"
  eval "$line"
}

installs() { reg-install "$@"; }
