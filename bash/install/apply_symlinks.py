#!/usr/bin/env python3
import argparse
import os
import shlex
import subprocess
import sys
from pathlib import Path


def parse_minimal_yaml_links(yaml_path: Path):
    links = []
    cur = None

    for raw in yaml_path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line == "links:":
            continue

        if line.startswith("- "):
            if cur:
                links.append(cur)
            cur = {}

            rest = line[2:].strip()
            if rest.startswith("source:"):
                cur["source"] = rest.split("source:", 1)[1].strip()
            elif rest.startswith("target:"):
                cur["target"] = rest.split("target:", 1)[1].strip()
            continue

        if cur is None:
            continue

        if line.startswith("source:"):
            cur["source"] = line.split("source:", 1)[1].strip()
        elif line.startswith("target:"):
            cur["target"] = line.split("target:", 1)[1].strip()

    if cur:
        links.append(cur)

    out = []
    for idx, item in enumerate(links, start=1):
        src = (item.get("source") or "").strip()
        tgt = (item.get("target") or "").strip()
        if not src or not tgt:
            raise ValueError(f"Invalid entry #{idx}: source and target are required")
        out.append({"source": src, "target": tgt})

    return out


def resolve_source(dotfiles_root: Path, src: str) -> Path:
    if src.startswith("/"):
        return Path(src)
    expanded = Path(os.path.expanduser(os.path.expandvars(src)))
    if expanded.is_absolute():
        return expanded
    return (dotfiles_root / src).resolve()


def resolve_target(home: Path, tgt: str) -> Path:
    if tgt.startswith("/"):
        return Path(tgt)
    expanded = Path(os.path.expanduser(os.path.expandvars(tgt)))
    if expanded.is_absolute():
        return expanded
    return (home / tgt).resolve()


def ensure_parent(path: Path, dry_run: bool):
    if dry_run:
        return
    path.parent.mkdir(parents=True, exist_ok=True)


def create_link(src: Path, tgt: Path, dry_run: bool):
    cmd = ["ln", "-sfn", str(src), str(tgt)]
    if dry_run:
        print("[dry-run] " + " ".join(shlex.quote(c) for c in cmd))
        return
    subprocess.run(cmd, check=True)


def main():
    parser = argparse.ArgumentParser(description="Apply symlinks from bash/install/symlinks.yml")
    parser.add_argument("--file", default=None, help="Path to symlinks.yml")
    parser.add_argument("--dry-run", action="store_true", help="Only print actions")
    parser.add_argument("--check", action="store_true", help="Fail if any source does not exist")
    args = parser.parse_args()

    script_dir = Path(__file__).resolve().parent
    yaml_path = Path(args.file).resolve() if args.file else (script_dir / "symlinks.yml")
    if not yaml_path.exists():
        print(f"ERROR: symlinks file not found: {yaml_path}", file=sys.stderr)
        return 2

    dotfiles_root = yaml_path.parent.parent.resolve()
    home = Path.home().resolve()

    try:
        links = parse_minimal_yaml_links(yaml_path)
    except Exception as exc:
        print(f"ERROR: failed to parse {yaml_path}: {exc}", file=sys.stderr)
        return 2

    errors = 0
    for item in links:
        src = resolve_source(dotfiles_root, item["source"])
        tgt = resolve_target(home, item["target"])

        if args.check and not src.exists():
            print(f"ERROR: missing source: {src}", file=sys.stderr)
            errors += 1
            continue

        if tgt.is_symlink():
            try:
                if (tgt.parent / tgt.readlink()).resolve() == src.resolve():
                    print(f"SKIP {tgt} already correct")
                    continue
            except OSError:
                pass

        ensure_parent(tgt, args.dry_run)

        try:
            create_link(src, tgt, args.dry_run)
        except subprocess.CalledProcessError as exc:
            print(f"ERROR: failed to link {tgt} -> {src}: {exc}", file=sys.stderr)
            errors += 1
            continue

        print(f"OK  {tgt} -> {src}")

    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())