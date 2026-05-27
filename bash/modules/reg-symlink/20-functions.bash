#!/usr/bin/env bash

reg-symlink() {
  local module_dir dotfiles_root file apply_script
  module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  dotfiles_root="$(cd "$module_dir/../../.." && pwd)"
  file="$dotfiles_root/bash/install/symlinks.yml"
  apply_script="$dotfiles_root/bash/install/apply_symlinks.py"

  if [[ $# -ne 2 ]]; then
    echo "usage: reg-symlink <source> <target>"
    echo "example: reg-symlink bash/bootstrap.sh .dotfiles/bootstrap.sh"
    return 1
  fi

  local source_path target_path ts
  source_path="$1"
  target_path="$2"

  if [[ ! -f "$file" ]]; then
    echo "[ERROR] symlinks file not found: $file"
    return 2
  fi

  if [[ ! -f "$apply_script" ]]; then
    echo "[ERROR] apply script not found: $apply_script"
    return 2
  fi

  if awk -v src="$source_path" -v tgt="$target_path" '
    BEGIN { in_item = 0; got_src = 0; got_tgt = 0 }
    /^[[:space:]]*-[[:space:]]+source:[[:space:]]*/ {
      if (in_item && got_src && got_tgt) found = 1
      in_item = 1
      got_src = 0
      got_tgt = 0
      line = $0
      sub(/^[[:space:]]*-[[:space:]]+source:[[:space:]]*/, "", line)
      if (line == src) got_src = 1
      next
    }
    /^[[:space:]]*target:[[:space:]]*/ {
      if (!in_item) next
      line = $0
      sub(/^[[:space:]]*target:[[:space:]]*/, "", line)
      if (line == tgt) got_tgt = 1
      next
    }
    END {
      if (in_item && got_src && got_tgt) found = 1
      exit(found ? 0 : 1)
    }
  ' "$file"; then
    echo "[ERROR] symlink entry may already exist: $source_path -> $target_path"
    return 3
  fi

  ts="$(date '+# [%Y-%m-%d %H:%M]')"

  {
    echo ""
    echo "$ts"
    echo "  - source: $source_path"
    echo "    target: $target_path"
  } >> "$file"

  echo "OK registered symlink: $source_path -> $target_path"

  if git -C "$dotfiles_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$dotfiles_root" add "bash/install/symlinks.yml"
    if git -C "$dotfiles_root" commit -m "reg-symlink: $source_path -> $target_path" >/dev/null 2>&1; then
      if git -C "$dotfiles_root" push >/dev/null 2>&1; then
        echo "pushed to origin"
      else
        echo "[WARN] commit feito, mas push falhou"
      fi
    fi
  fi

  echo "running: python3 $apply_script"
  python3 "$apply_script"
}

symlink() { reg-symlink "$@"; }