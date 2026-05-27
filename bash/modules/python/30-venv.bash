#!/usr/bin/env bash

venv() {
  python3 -m venv .venv || return 1
  # shellcheck disable=SC1091
  source .venv/bin/activate || return 1
  python3 -m pip install --upgrade pip >/dev/null || return 1
  [[ -f requirements.txt ]] || touch requirements.txt
  pip install -r requirements.txt
}
