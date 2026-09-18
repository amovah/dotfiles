#!/usr/bin/env bash
# Install the official Blender Lab MCP server and register it with Claude Code,
# Codex and OpenCode.
#
# Two pieces have to line up for this to work:
#
#   MCP client  ⇐ stdio ⇒  blender-mcp  ⇐ TCP :9876 ⇒  Blender add-on
#
# The add-on ships as a Blender extension and is installed into Blender itself.
# The server is a Python package needing 3.10+, which macOS does not provide, so
# it gets its own venv under ~/.local/share/blender-mcp rather than fighting the
# system interpreter.
#
# Run with no arguments to do everything, name clients as arguments to register
# just those, or --uninstall to reverse the whole thing.
#
# Re-running is safe: the venv is rebuilt, the extension is reinstalled over
# itself, and client entries are replaced rather than duplicated.

set -euo pipefail

version=v1.0.3
prefix="$HOME/.local/share/blender-mcp"
venv="$prefix/venv"
server_bin="$venv/bin/blender-mcp"
repo_url=https://projects.blender.org/lab/blender_mcp.git
release_url="https://projects.blender.org/lab/blender_mcp/releases/download/$version/mcp-${version#v}.zip"
opencode_config="$HOME/.config/opencode/opencode.json"

dry_run=false
uninstall=false
requested=()

all_clients=(claude codex opencode)

usage() {
  cat <<USAGE
usage: setup-blender-mcp.sh [--dry-run] [--uninstall] [client ...]

  client       one or more of: ${all_clients[*]} (default: all of them)
  --dry-run    print what would happen, change nothing
  --uninstall  remove the server, the add-on, and the client entries
  -h           show this help

environment:
  BLENDER_BIN  path to the Blender binary (default: the macOS app bundle)
USAGE
}

for arg in "$@"; do
  case "$arg" in
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
    *)
      case " ${all_clients[*]} " in
        *" $arg "*) requested+=("$arg") ;;
        *)
          echo "unknown client: $arg (want one of: ${all_clients[*]})" >&2
          exit 2
          ;;
      esac
      ;;
  esac
done

clients=("${requested[@]:-${all_clients[@]}}")

# Progress goes to stderr throughout, so that helpers which echo a value for
# capture (ensure_python) are not polluted by their own logging.
log() { printf '\033[1m==>\033[0m %s\n' "$*" >&2; }
step() { printf '    %s\n' "$*" >&2; }
die() {
  printf '\033[31merror:\033[0m %s\n' "$*" >&2
  exit 1
}

# Echo and run, or just echo under --dry-run.
run() {
  if $dry_run; then
    printf '    [dry-run] %s\n' "$*" >&2
  else
    "$@"
  fi
}

# Like run(), for commands whose own chatter is not worth showing. The redirect
# has to live in here: written at the call site it would swallow the --dry-run
# notice too, and the step that follows would claim work that never happened.
run_quiet() {
  if $dry_run; then
    printf '    [dry-run] %s\n' "$*" >&2
  else
    "$@" >/dev/null 2>&1
  fi
}

# --- Blender -----------------------------------------------------------------

# The add-on requires 5.1, which is where Blender's LLM-facing Python API landed.
find_blender() {
  local candidate
  for candidate in \
    "${BLENDER_BIN:-}" \
    /Applications/Blender.app/Contents/MacOS/Blender \
    "$(command -v blender 2>/dev/null || true)"; do
    [[ -n $candidate && -x $candidate ]] && {
      echo "$candidate"
      return 0
    }
  done
  return 1
}

check_blender_version() {
  local blender=$1 version_line major minor
  version_line=$("$blender" --version 2>/dev/null | head -1)
  major=$(echo "$version_line" | sed -nE 's/^Blender ([0-9]+)\.([0-9]+).*/\1/p')
  minor=$(echo "$version_line" | sed -nE 's/^Blender ([0-9]+)\.([0-9]+).*/\2/p')
  [[ -z $major ]] && die "could not read a version from: $version_line"
  if ((major < 5 || (major == 5 && minor < 1))); then
    die "the MCP add-on needs Blender 5.1 or newer, found: $version_line"
  fi
  step "$version_line"
}

# --- Python ------------------------------------------------------------------

# The server declares requires-python >=3.10. System python3 on macOS is 3.9, so
# look for a newer one and let Homebrew supply it when there is none.
find_python() {
  local candidate
  for candidate in python3.14 python3.13 python3.12 python3.11 python3.10; do
    if command -v "$candidate" >/dev/null 2>&1; then
      command -v "$candidate"
      return 0
    fi
  done
  if command -v python3 >/dev/null 2>&1 &&
    python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)' 2>/dev/null; then
    command -v python3
    return 0
  fi
  return 1
}

ensure_python() {
  local python
  if python=$(find_python); then
    step "$python ($("$python" -V 2>&1))"
    echo "$python"
    return 0
  fi

  command -v brew >/dev/null 2>&1 ||
    die "no Python 3.10+ found and no Homebrew to install one; install Python 3.10+ and re-run"

  # The unversioned formula, so this keeps working across major bumps and does
  # not leave a pinned python@3.N behind for every year it was first run.
  step "no Python 3.10+ found, installing python3 with Homebrew"
  run brew install python3
  $dry_run && {
    echo python3
    return 0
  }
  python=$(find_python) || die "Homebrew finished but no Python 3.10+ is on PATH"
  echo "$python"
}

# --- install / uninstall steps -----------------------------------------------

install_server() {
  local python=$1
  log "Installing the MCP server into $venv"
  run rm -rf "$venv"
  run "$python" -m venv "$venv"
  run "$venv/bin/python" -m pip install --quiet --upgrade pip
  # Installed from the tag rather than main so the server and the add-on below
  # are the same release.
  run "$venv/bin/python" -m pip install --quiet "git+$repo_url@$version#subdirectory=mcp"
  $dry_run || [[ -x $server_bin ]] || die "expected $server_bin after install, it is missing"
  step "$server_bin"
}

install_addon() {
  local blender=$1 tmp zip
  log "Installing the Blender add-on ($version)"
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' RETURN
  zip="$tmp/mcp-${version#v}.zip"
  run curl -fsSL -o "$zip" "$release_url"
  # user_default is the local repository every Blender install already has, so
  # this needs no extra remote repository registered.
  run "$blender" --command extension install-file --repo user_default --enable "$zip"
  step "installed and enabled; the bridge server auto-starts with Blender on port 9876"
}

remove_addon() {
  local blender=$1
  log "Removing the Blender add-on"
  run "$blender" --command extension remove mcp || step "add-on was not installed"
}

remove_server() {
  log "Removing $prefix"
  run rm -rf "$prefix"
}

# --- MCP clients -------------------------------------------------------------

register_claude() {
  command -v claude >/dev/null 2>&1 || {
    step "claude not on PATH, skipping"
    return 0
  }
  # Replace rather than add, so re-running does not fail on a duplicate name.
  run_quiet claude mcp remove --scope user blender || true
  run claude mcp add --scope user blender -- "$server_bin"
  step "claude: added at user scope"
}

unregister_claude() {
  command -v claude >/dev/null 2>&1 || return 0
  run_quiet claude mcp remove --scope user blender || true
  $dry_run || step "claude: removed"
}

register_codex() {
  command -v codex >/dev/null 2>&1 || {
    step "codex not on PATH, skipping"
    return 0
  }
  run_quiet codex mcp remove blender || true
  run codex mcp add blender -- "$server_bin"
  step "codex: added to ~/.codex/config.toml"
}

unregister_codex() {
  command -v codex >/dev/null 2>&1 || return 0
  run_quiet codex mcp remove blender || true
  $dry_run || step "codex: removed"
}

# OpenCode has no CLI for this, so edit its JSON in place -- merging so any
# other servers and unrelated settings survive.
edit_opencode_config() {
  local mode=$1
  python3 - "$opencode_config" "$mode" "$server_bin" <<'PYTHON'
import json
import os
import sys

path, mode, server_bin = sys.argv[1], sys.argv[2], sys.argv[3]

config = {}
if os.path.exists(path):
    with open(path, encoding="utf-8") as fh:
        text = fh.read().strip()
    if text:
        config = json.loads(text)

config.setdefault("$schema", "https://opencode.ai/config.json")
servers = config.setdefault("mcp", {})

if mode == "add":
    servers["blender"] = {
        "type": "local",
        "command": [server_bin],
        "enabled": True,
    }
else:
    servers.pop("blender", None)
    if not servers:
        config.pop("mcp", None)

os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w", encoding="utf-8") as fh:
    json.dump(config, fh, indent=2)
    fh.write("\n")
PYTHON
}

register_opencode() {
  command -v opencode >/dev/null 2>&1 || {
    step "opencode not on PATH, skipping"
    return 0
  }
  if $dry_run; then
    step "[dry-run] add mcp.blender to $opencode_config"
  else
    edit_opencode_config add
    step "opencode: added to $opencode_config"
  fi
}

unregister_opencode() {
  [[ -f $opencode_config ]] || return 0
  if $dry_run; then
    step "[dry-run] remove mcp.blender from $opencode_config"
  else
    edit_opencode_config remove
    step "opencode: removed"
  fi
}

# --- main --------------------------------------------------------------------

blender=$(find_blender) || die "no Blender binary found; set BLENDER_BIN to its path"

if $uninstall; then
  log "Unregistering clients"
  for client in "${clients[@]}"; do "unregister_$client"; done
  remove_addon "$blender"
  remove_server
  log "Done."
  exit 0
fi

log "Checking Blender"
check_blender_version "$blender"

log "Checking Python"
python=$(ensure_python)

install_server "$python"
install_addon "$blender"

log "Registering clients: ${clients[*]}"
for client in "${clients[@]}"; do "register_$client"; done

cat <<NEXT

$(printf '\033[1m==>\033[0m') Done.

    Open Blender and leave it running -- the add-on's bridge server starts a few
    seconds after launch and the MCP tools do nothing without it. Confirm under
    Edit > Preferences > Add-ons > MCP.

    Then, in any of the three clients, ask for something like:
      "Summarise the current Blender scene"
      "Build a 12x12 hex grid of beveled tiles with random height variation"

    Heads up: execute_blender_code runs model-written Python in Blender with no
    sandbox. Save your work first, and keep sensitive .blend files out of reach.

    Undo all of this with: ./setup-blender-mcp.sh --uninstall
NEXT
