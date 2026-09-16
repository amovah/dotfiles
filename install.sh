#!/usr/bin/env bash
# Symlink files under home/ into $HOME at the matching path.
#
#   home/.config/zellij/config.kdl  ->  ~/.config/zellij/config.kdl
#
# Files are grouped by the app they configure (zellij, nvim, claude-code, ...),
# and each app is one item in the install menu. Items that are not config files
# -- fonts, and the macOS-only nosleep -- sit in `extras` alongside them.
#
# Run with no arguments to pick items from a menu, name items as arguments to
# install just those, or use --all to install everything without prompting.
#
# Existing real files are moved aside to <file>.backup before linking.
# Re-running is safe: correct links and installed fonts are left alone.
#
# --uninstall reverses all of that, and is what uninstall.sh calls. Both
# directions share this file so the menu and the item list cannot drift apart.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_root="$repo_root/home"

dry_run=false
select_all=false
uninstall=false
requested=()

usage() {
  local prog=install.sh verb=install
  if $uninstall; then
    prog=uninstall.sh
    verb=uninstall
  fi

  cat <<USAGE
usage: $prog [--all] [--dry-run] [item ...]

  item       one or more items to $verb (see the menu for the full list)
  --all      $verb every item, no prompt
  --dry-run  print what would happen, change nothing
  -h         show this help
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --all) select_all=true ;;
    --dry-run) dry_run=true ;;
    --uninstall) uninstall=true ;;
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

is_macos() {
  [[ "$(uname -s)" == Darwin ]]
}

# Menu items that are not symlinked config files. Each needs a case in
# label(), install_item() and uninstall_item().
extras=(fonts)

# nosleep drives pmset, which only exists on macOS.
if is_macos; then
  extras+=(nosleep)
fi

items=("${apps[@]}" "${extras[@]}")

# Widest item name, so the menu columns line up.
item_width=0
for item in "${items[@]}"; do
  [[ ${#item} -gt $item_width ]] && item_width=${#item}
done

files_of() {
  local want="$1" i
  for ((i = 0; i < ${#names[@]}; i++)); do
    [[ "${file_apps[$i]}" == "$want" ]] && echo "${names[$i]}"
  done
}

# The Nerd Font the ghostty config asks for.
nerd_font=UbuntuMono

font_dir() {
  if is_macos; then
    echo "$HOME/Library/Fonts"
  else
    echo "${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
  fi
}

font_installed() {
  compgen -G "$(font_dir)/${nerd_font}NerdFont*.ttf" >/dev/null
}

# The pmset keys the nosleep item owns, and the AC-power value each takes while
# it is installed, as parallel arrays. `sleep 0` stops the machine suspending
# after an idle stretch; `disablesleep 1` stops the suspend a closed lid would
# trigger. Both are needed to keep background work running, and neither touches
# the battery profile.
nosleep_keys=(sleep disablesleep)
nosleep_values=(0 1)

# What the keys held before we changed them, so uninstall can put them back.
nosleep_backup="$HOME/.config/dotfiles/nosleep.backup"

# The AC-power value of one pmset key. `disablesleep` is not part of that
# profile's listing -- pmset reports it among the system-wide settings, and only
# once it is on, so an absent line means 0.
pmset_ac() {
  if [[ "$1" == disablesleep ]]; then
    pmset -g | awk '$1 == "SleepDisabled" { print $2; hit = 1 }
                    END { if (!hit) print 0 }'
    return
  fi

  pmset -g custom | awk -v key="$1" '
    /^AC Power:/    { ac = 1; next }
    /^[^[:space:]]/ { ac = 0 }
    ac && $1 == key { print $2; exit }
  '
}

nosleep_active() {
  local i
  for ((i = 0; i < ${#nosleep_keys[@]}; i++)); do
    [[ "$(pmset_ac "${nosleep_keys[$i]}")" == "${nosleep_values[$i]}" ]] || return 1
  done
}

# The owned keys and their current AC values on one line, for the log.
nosleep_current() {
  local key out=()
  for key in "${nosleep_keys[@]}"; do
    out+=("$key" "$(pmset_ac "$key")")
  done
  echo "${out[*]}"
}

is_linked() {
  local dest="$HOME/$1"
  [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src_root/$1")" ]]
}

# One menu row. Every state marker is 8 columns wide so the rows line up.
label() {
  case "$1" in
    fonts) label_fonts ;;
    nosleep) label_nosleep ;;
    *) label_app "$1" ;;
  esac
}

# "zellij  [linked] 2 files" / "nvim  [ 1/3 ] 3 files" / "nvim  [      ] 3 files"
label_app() {
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

  printf "%-${item_width}s %s %d file" "$app" "$state" "$total"
  [[ "$total" -ne 1 ]] && printf 's'
  printf '\n'
}

# "fonts   [  ok  ] UbuntuMono Nerd Font"
label_fonts() {
  local state="[      ]"
  font_installed && state="[  ok  ]"
  printf "%-${item_width}s %s %s Nerd Font\n" fonts "$state" "$nerd_font"
}

# "nosleep [  ok  ] awake on AC power"
label_nosleep() {
  local state="[      ]"
  nosleep_active && state="[  ok  ]"
  printf "%-${item_width}s %s awake on AC power\n" nosleep "$state"
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

# Download a font from the ryanoasis/nerd-fonts releases into the user font
# directory. The argument is a release asset name without the .zip; see
# https://github.com/ryanoasis/nerd-fonts/releases for the full list.
install_nerd_font() {
  local font="$1"
  local version="${NERD_FONT_VERSION:-v3.5.1}"
  local url work ttf count=0
  local dir
  dir="$(font_dir)"

  if font_installed; then
    echo "  ok      $font Nerd Font already in $dir"
    return
  fi

  url="https://github.com/ryanoasis/nerd-fonts/releases/download/$version/$font.zip"

  if $dry_run; then
    echo "  would install $font Nerd Font $version -> $dir"
    return
  fi

  work="$(mktemp -d)"

  echo "  fetch   $url"
  if ! curl -fsSL --retry 3 -o "$work/$font.zip" "$url"; then
    rm -rf "$work"
    echo "download failed: $url" >&2
    echo "check the asset name against $version's release page" >&2
    return 1
  fi

  unzip -oq "$work/$font.zip" -d "$work/font"

  mkdir -p "$dir"
  while IFS= read -r -d '' ttf; do
    cp "$ttf" "$dir/"
    count=$((count + 1))
  done < <(find "$work/font" -name '*.ttf' -print0)

  rm -rf "$work"

  if [[ "$count" -eq 0 ]]; then
    echo "no .ttf files in $font.zip" >&2
    return 1
  fi

  echo "  font    $count files -> $dir"

  # macOS picks new fonts up on its own; fontconfig needs a nudge.
  command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$dir" >/dev/null

  return 0
}

# Stop the machine suspending while it is on the power adapter, so a long
# background job survives an idle stretch or a closed lid. This is the one item
# that needs root, so it is the one that can ask for a password -- when nothing
# can answer, it is skipped rather than left hanging. The values being replaced
# are written to $nosleep_backup first, the way a displaced config file is kept
# as <file>.backup, and remove_nosleep reads them back.
install_nosleep() {
  local i key args=()

  if nosleep_active; then
    echo "  ok      already awake on AC power"
    return
  fi

  for ((i = 0; i < ${#nosleep_keys[@]}; i++)); do
    args+=("${nosleep_keys[$i]}" "${nosleep_values[$i]}")
  done

  if $dry_run; then
    [[ -e "$nosleep_backup" ]] ||
      echo "  would save AC $(nosleep_current) -> $nosleep_backup"
    echo "  would run  sudo pmset -c ${args[*]}"
    return
  fi

  if ! sudo -n true 2>/dev/null && [[ ! -t 0 ]]; then
    echo "  skip    needs sudo, and there is no terminal to ask on"
    return
  fi

  # Only the first install records a backup: a second one would capture the
  # values we ourselves put there and make the uninstall a no-op.
  if [[ ! -e "$nosleep_backup" ]]; then
    mkdir -p "$(dirname "$nosleep_backup")"
    for key in "${nosleep_keys[@]}"; do
      echo "$key $(pmset_ac "$key")"
    done >"$nosleep_backup"
    echo "  backup  AC $(nosleep_current) -> $nosleep_backup"
  fi

  sudo pmset -c "${args[@]}"
  echo "  pmset   AC ${args[*]}"
}

# Remove a symlink this repo owns, putting back whatever it displaced. Anything
# we did not create -- a real file, or a link pointing somewhere else -- is left
# where it is.
unlink_file() {
  local name="$1"
  local src="$src_root/$name"
  local dest="$HOME/$name"

  if [[ ! -e "$dest" && ! -L "$dest" ]]; then
    echo "  gone    $dest"
    return
  fi

  if [[ ! -L "$dest" ]]; then
    echo "  skip    $dest (real file, not ours)"
    return
  fi

  if [[ "$(readlink -f "$dest")" != "$(readlink -f "$src")" ]]; then
    echo "  skip    $dest (links elsewhere)"
    return
  fi

  if $dry_run; then
    echo "  would unlink $dest"
    [[ -e "$dest.backup" ]] && echo "  would restore $dest.backup -> $dest"
    return 0
  fi

  rm -f "$dest"
  echo "  unlink  $dest"

  if [[ -e "$dest.backup" ]]; then
    mv "$dest.backup" "$dest"
    echo "  restore $dest.backup -> $dest"
    return
  fi

  prune_dirs "$(dirname "$dest")"

  return 0
}

# Walk up from a directory an unlink emptied, clearing what is left. rmdir only
# succeeds on an empty directory, so a dir still holding anything stops this.
# $HOME itself is never a candidate.
prune_dirs() {
  local dir="$1"
  while [[ "$dir" != "$HOME" && "$dir" != "/" ]]; do
    rmdir "$dir" 2>/dev/null || break
    echo "  rmdir   $dir"
    dir="$(dirname "$dir")"
  done
}

# Delete the font files install_nerd_font laid down, and nothing else in there.
remove_nerd_font() {
  local font="$1" ttf count=0
  local dir
  dir="$(font_dir)"

  if ! font_installed; then
    echo "  gone    $font Nerd Font not in $dir"
    return
  fi

  if $dry_run; then
    echo "  would remove $font Nerd Font from $dir"
    return
  fi

  while IFS= read -r -d '' ttf; do
    rm -f "$ttf"
    count=$((count + 1))
  done < <(find "$dir" -maxdepth 1 -name "${font}NerdFont*.ttf" -print0)

  echo "  remove  $count files from $dir"

  command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$dir" >/dev/null

  return 0
}

# Put back the pmset values install_nosleep displaced. With no backup file --
# never installed, or it was cleared by hand -- there is no recorded state to
# return to, so the settings are left exactly as they are.
remove_nosleep() {
  local key value args=()

  if [[ ! -e "$nosleep_backup" ]]; then
    echo "  gone    nothing recorded in $nosleep_backup"
    return
  fi

  while read -r key value; do
    [[ -n "$key" ]] || continue
    args+=("$key" "$value")
  done <"$nosleep_backup"

  if [[ ${#args[@]} -eq 0 ]]; then
    echo "  skip    $nosleep_backup is empty"
    return
  fi

  if $dry_run; then
    echo "  would run    sudo pmset -c ${args[*]}"
    echo "  would remove $nosleep_backup"
    return
  fi

  if ! sudo -n true 2>/dev/null && [[ ! -t 0 ]]; then
    echo "  skip    needs sudo, and there is no terminal to ask on"
    return
  fi

  sudo pmset -c "${args[@]}"
  echo "  pmset   AC ${args[*]}"

  rm -f "$nosleep_backup"
  echo "  remove  $nosleep_backup"
  prune_dirs "$(dirname "$nosleep_backup")"
}

install_item() {
  local item="$1" file
  echo "$item"
  case "$item" in
    fonts) install_nerd_font "$nerd_font" ;;
    nosleep) install_nosleep ;;
    *)
      while IFS= read -r file; do
        link "$file"
      done < <(files_of "$item")
      ;;
  esac
}

uninstall_item() {
  local item="$1" file
  echo "$item"
  case "$item" in
    fonts) remove_nerd_font "$nerd_font" ;;
    nosleep) remove_nosleep ;;
    *)
      while IFS= read -r file; do
        unlink_file "$file"
      done < <(files_of "$item")
      ;;
  esac
}

pick_with_fzf() {
  local item
  for item in "${items[@]}"; do
    label "$item"
  done |
    fzf --multi \
      --layout=reverse \
      --height=60% \
      --prompt="$($uninstall && echo uninstall || echo install)> " \
      --header=$'up/down: move   tab: toggle   ctrl-a: all   ctrl-d: none   enter: confirm   esc: cancel\n' \
      --bind='ctrl-a:select-all,ctrl-d:deselect-all' |
    awk '{print $1}'
}

# Numbered fallback: "1 3-5" picks those apps, "a" picks all, "q" quits.
# Appends to the global `selected` array; reads the answer from the terminal so
# it does not compete with anything piped into the script.
pick_with_prompt() {
  local i reply token start end

  for ((i = 0; i < ${#items[@]}; i++)); do
    printf '  %2d) %s\n' "$((i + 1))" "$(label "${items[$i]}")"
  done

  printf '\nselect (e.g. "1 3-5", "a" for all, "q" to quit): '
  read -r reply </dev/tty || reply=q
  echo

  case "$reply" in
    q | Q | "") return 0 ;;
    a | A | all)
      selected=("${items[@]}")
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
      if [[ "$i" -lt 1 || "$i" -gt ${#items[@]} ]]; then
        echo "out of range: $i" >&2
        continue
      fi
      selected+=("${items[$((i - 1))]}")
    done
  done
}

selected=()

if [[ ${#requested[@]} -gt 0 ]]; then
  for want in "${requested[@]}"; do
    found=false
    for item in "${items[@]}"; do
      [[ "$item" == "$want" ]] && found=true && break
    done
    if $found; then
      selected+=("$want")
    else
      echo "unknown item: $want" >&2
      echo "known items: ${items[*]}" >&2
      exit 2
    fi
  done
elif $select_all || [[ ! -t 0 && ! -t 1 ]]; then
  selected=("${items[@]}")
elif command -v fzf >/dev/null 2>&1; then
  while IFS= read -r item; do
    selected+=("$item")
  done < <(pick_with_fzf)
else
  pick_with_prompt
fi

if [[ ${#selected[@]} -eq 0 ]]; then
  echo "nothing selected"
  exit 0
fi

for item in "${selected[@]}"; do
  if $uninstall; then
    uninstall_item "$item"
  else
    install_item "$item"
  fi
done
