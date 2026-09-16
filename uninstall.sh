#!/usr/bin/env bash
# Reverse of install.sh, with the same menu and the same flags:
#
#   ./uninstall.sh                 # pick items from a menu
#   ./uninstall.sh zellij fonts    # uninstall named items
#   ./uninstall.sh --all           # every item, no prompt
#   ./uninstall.sh --dry-run       # preview, changes nothing
#
# Tracked configs are unlinked and any <file>.backup is moved back into place;
# directories left empty are cleared; the Nerd Font is deleted; the pmset values
# nosleep replaced are restored from what it recorded. Anything this repo did not
# create is left alone.
#
# The work lives in install.sh behind --uninstall, so the two directions cannot
# drift apart as items are added.

set -euo pipefail

exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install.sh" --uninstall "$@"
