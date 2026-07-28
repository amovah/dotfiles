#!/usr/bin/env bash
# Symlink every file under home/ into $HOME at the matching path.
#
#   home/.config/zellij/config.kdl  ->  ~/.config/zellij/config.kdl
#
# Existing real files are moved aside to <file>.backup before linking.
# Re-running is safe: correct links are left alone.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_root="$repo_root/home"

dry_run=false
[[ "${1:-}" == "--dry-run" ]] && dry_run=true

link() {
  local src="$1" dest="$2"

  if [[ -L "$dest" && "$(readlink -f "$dest")" == "$src" ]]; then
    echo "  ok      $dest"
    return
  fi

  if $dry_run; then
    echo "  would link $dest -> $src"
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mv "$dest" "$dest.backup"
    echo "  backup  $dest -> $dest.backup"
  fi

  ln -sfn "$src" "$dest"
  echo "  link    $dest"
}

while IFS= read -r -d '' src; do
  link "$src" "$HOME/${src#"$src_root/"}"
done < <(find "$src_root" -type f -print0 | sort -z)
