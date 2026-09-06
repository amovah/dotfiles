#!/usr/bin/env bash
# Symlink files under home/ into $HOME at the matching path.
#
#   home/.config/zellij/config.kdl  ->  ~/.config/zellij/config.kdl
#
# Files are grouped by the app they configure (zellij, nvim, claude-code, ...).
# Run with no arguments to pick apps from a menu, name apps as arguments to
# install just those, or use --all to install everything without prompting.
#
# Existing real files are moved aside to <file>.backup before linking.
# Re-running is safe: correct links are left alone.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_root="$repo_root/home"

dry_run=false
select_all=false
requested=()

usage() {
  cat <<'USAGE'
usage: install.sh [--all] [--dry-run] [app ...]

  app        one or more app names to install (see the list below)
  --all      install every app, no prompt
  --dry-run  print what would happen, change nothing
  -h         show this help
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --all) select_all=true ;;
    --dry-run) dry_run=true ;;
    -h | --help)
      usage
      exit 0
      ;;
    -*)
      echo "unknown option: $arg" >&2
      usage >&2
      exit 2
      ;;
    *) requested+=("$arg") ;;
  esac
done

# Which app a tracked file belongs to. Add a case here when tracking a new app.
app_for() {
  case "$1" in
    .config/zellij/*) echo zellij ;;
    .config/nvim/*) echo nvim ;;
    .config/fish/*) echo fish ;;
    .config/ghostty/*) echo ghostty ;;
    .claude/* | .claude.json) echo claude-code ;;
    .markdownlint-cli2.* | .markdownlint.*) echo markdownlint ;;
    .gitconfig | .gitignore_global) echo git ;;
    .config/*) echo "${1#.config/}" | cut -d/ -f1 ;;
    *) echo misc ;;
  esac
}

# Tracked files, relative to home/, and their app, as parallel arrays.
names=()
file_apps=()
while IFS= read -r -d '' src; do
  name="${src#"$src_root/"}"
  names+=("$name")
  file_apps+=("$(app_for "$name")")
done < <(find "$src_root" -type f -print0 | sort -z)

if [[ ${#names[@]} -eq 0 ]]; then
  echo "nothing to link: $src_root is empty" >&2
  exit 1
fi

# Distinct app names, in the order their first file appears.
apps=()
for app in "${file_apps[@]}"; do
  known=false
  for seen in ${apps[@]+"${apps[@]}"}; do
    [[ "$seen" == "$app" ]] && known=true && break
  done
  $known || apps+=("$app")
done

# Widest app name, so the menu columns line up.
app_width=0
for app in "${apps[@]}"; do
  [[ ${#app} -gt $app_width ]] && app_width=${#app}
done

files_of() {
  local want="$1" i
  for ((i = 0; i < ${#names[@]}; i++)); do
    [[ "${file_apps[$i]}" == "$want" ]] && echo "${names[$i]}"
  done
}

is_linked() {
  local dest="$HOME/$1"
  [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src_root/$1")" ]]
}

# "zellij  [linked] 2 files" / "nvim  [ 1/3 ] 3 files" / "nvim  [      ] 3 files"
label() {
  local app="$1" total=0 linked=0 file state
  while IFS= read -r file; do
    total=$((total + 1))
    is_linked "$file" && linked=$((linked + 1))
  done < <(files_of "$app")

  if [[ "$linked" -eq "$total" ]]; then
    state="[linked]"
  elif [[ "$linked" -eq 0 ]]; then
    state="[      ]"
  else
    state="[ $linked/$total  ]"
  fi

  printf "%-${app_width}s %s %d file" "$app" "$state" "$total"
  [[ "$total" -ne 1 ]] && printf 's'
  printf '\n'
}

link() {
  local name="$1"
  local src="$src_root/$name"
  local dest="$HOME/$name"

  if is_linked "$name"; then
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

install_app() {
  local app="$1" file
  echo "$app"
  while IFS= read -r file; do
    link "$file"
  done < <(files_of "$app")
}

pick_with_fzf() {
  local app
  for app in "${apps[@]}"; do
    label "$app"
  done |
    fzf --multi \
      --layout=reverse \
      --height=60% \
      --prompt='install> ' \
      --header=$'up/down: move   tab: toggle   ctrl-a: all   ctrl-d: none   enter: confirm   esc: cancel\n' \
      --bind='ctrl-a:select-all,ctrl-d:deselect-all' |
    awk '{print $1}'
}

# Numbered fallback: "1 3-5" picks those apps, "a" picks all, "q" quits.
# Appends to the global `selected` array; reads the answer from the terminal so
# it does not compete with anything piped into the script.
pick_with_prompt() {
  local i reply token start end

  for ((i = 0; i < ${#apps[@]}; i++)); do
    printf '  %2d) %s\n' "$((i + 1))" "$(label "${apps[$i]}")"
  done

  printf '\nselect (e.g. "1 3-5", "a" for all, "q" to quit): '
  read -r reply </dev/tty || reply=q
  echo

  case "$reply" in
    q | Q | "") return 0 ;;
    a | A | all)
      selected=("${apps[@]}")
      return 0
      ;;
  esac

  for token in ${reply//,/ }; do
    if [[ "$token" =~ ^[0-9]+-[0-9]+$ ]]; then
      start="${token%-*}"
      end="${token#*-}"
    elif [[ "$token" =~ ^[0-9]+$ ]]; then
      start="$token"
      end="$token"
    else
      echo "ignoring: $token" >&2
      continue
    fi

    for ((i = start; i <= end; i++)); do
      if [[ "$i" -lt 1 || "$i" -gt ${#apps[@]} ]]; then
        echo "out of range: $i" >&2
        continue
      fi
      selected+=("${apps[$((i - 1))]}")
    done
  done
}

selected=()

if [[ ${#requested[@]} -gt 0 ]]; then
  for want in "${requested[@]}"; do
    found=false
    for app in "${apps[@]}"; do
      [[ "$app" == "$want" ]] && found=true && break
    done
    if $found; then
      selected+=("$want")
    else
      echo "unknown app: $want" >&2
      echo "known apps: ${apps[*]}" >&2
      exit 2
    fi
  done
elif $select_all || [[ ! -t 0 && ! -t 1 ]]; then
  selected=("${apps[@]}")
elif command -v fzf >/dev/null 2>&1; then
  while IFS= read -r app; do
    selected+=("$app")
  done < <(pick_with_fzf)
else
  pick_with_prompt
fi

if [[ ${#selected[@]} -eq 0 ]]; then
  echo "nothing selected"
  exit 0
fi

for app in "${selected[@]}"; do
  install_app "$app"
done
