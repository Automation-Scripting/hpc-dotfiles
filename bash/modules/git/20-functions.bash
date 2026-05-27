#!/usr/bin/env bash

gh_clone_org_repos() {
  if ! command -v gh >/dev/null 2>&1; then
    echo "gh CLI nao encontrado. Instale o GitHub CLI para usar esta funcao."
    return 1
  fi

  local org
  org="$(basename "$PWD")"

  echo "[info] Org detectada: $org"
  echo "[info] Destino: $PWD"

  gh repo list "$org" \
    --limit 1000 \
    --json name,sshUrl \
    -q '.[] | [.name, .sshUrl] | @tsv' |
  while IFS=$'\t' read -r name ssh; do
    if [[ -d "${name}/.git" ]]; then
      echo "[skip] ${name} ja existe"
    else
      echo "[clone] ${ssh}"
      git clone "${ssh}"
    fi
  done

  echo "[ok] Concluido."
}
