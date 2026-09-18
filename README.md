# dotfiles

My personal setup on Ubuntu. `install.sh` also runs on macOS; the package
commands below list both.

## Install

Everything under `home/` mirrors `$HOME`. `install.sh` symlinks each file to its
matching path, backing up any existing real file as `<file>.backup`. Files are
grouped by the app they configure, and each app is one menu item. Things that
are not config files — `fonts` and `nosleep` — are menu items too:

```
./install.sh                  # pick items from a menu
./install.sh zellij fonts     # install named items
./install.sh --all            # every item, no prompt
./install.sh --dry-run        # preview, changes nothing (combines with the above)
```

The menu uses [fzf](https://junegunn.github.io/fzf/) when it is installed
(`up`/`down` to move, `tab` to toggle, `ctrl-a` for all, `ctrl-d` for none,
`enter` to confirm, `esc` to cancel), and falls back to a numbered prompt
otherwise (`1 3-5`, `a` for all, `q` to quit). Either way each row shows what
is already in place — how many of an app's files are linked, or whether the
font is installed:

```
  1) ghostty      [linked] 1 file
  2) nvim         [      ] 3 files
  3) zellij       [ 1/2  ] 2 files
  4) markdownlint [      ] 1 file
  5) fonts        [  ok  ] UbuntuMono Nerd Font
  6) nosleep      [      ] awake on AC power
```

With no terminal attached it installs everything, so it stays usable from
another script.

Non-config items live in the `extras` array, with a case each in `label()` and
`install_item()`. `fonts` fetches the font ghostty is configured for from the
[Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases),
unpacking into `~/Library/Fonts` on macOS and `~/.local/share/fonts` (plus
`fc-cache`) elsewhere. It skips a font that is already installed and honours
`--dry-run`. The font name is the `nerd_font` variable; the release tag is
pinned next to it and `NERD_FONT_VERSION` overrides it.

`nosleep` keeps the machine running while it is on the power adapter, so a long
background job is not cut short by an idle stretch or a closed lid. It sets two
`pmset` values on the AC profile — `sleep 0` for the idle suspend and
`disablesleep 1` for the lid-close one — and leaves the battery profile alone.
Display sleep is untouched either way: the screen going dark does not stop
anything running.

It is the one item that needs `sudo`, and the only one that will ask for a
password; with no terminal to ask on it prints `skip` rather than hanging. It is
also macOS-only, so it is absent from the menu everywhere else. The values it
replaces are written to `~/.config/dotfiles/nosleep.backup` first, which is what
the uninstall reads to put them back — the same idea as a `<file>.backup`.

Picking `ghostty` alone installs only its config — the font is a separate
choice, so select `fonts` too (or `--all`).

### Uninstall

`uninstall.sh` reverses all of it, with the same menu and the same flags:

```
./uninstall.sh                # pick items from a menu
./uninstall.sh zellij fonts   # uninstall named items
./uninstall.sh --all          # every item, no prompt
./uninstall.sh --dry-run      # preview, changes nothing
```

Tracked configs are unlinked, any `<file>.backup` is moved back into place, and
directories left empty are cleared (`rmdir` only touches an empty one, so a
directory still holding anything of yours survives). `fonts` deletes the font
files it installed and nothing else in the font directory. `nosleep` restores
the `pmset` values recorded at install time, then deletes the record; with no
record — never installed, or cleared by hand — it reports `gone` and changes
nothing, since there is no state it can safely return you to.

Anything this repo did not create is left where it is, reported as `skip`: a
real file at a tracked path, or a symlink pointing somewhere other than into
this repo. The one gap is on the install side — `install.sh` only backs up
*real* files, so a symlink you had pointing elsewhere is replaced silently and
uninstall has nothing to restore.

The work lives in `install.sh` behind `--uninstall`, which `uninstall.sh`
execs, so the two directions share one item list and one menu.

Tracked configs:

| App | Repo path | Links to |
| --- | --- | --- |
| `nvim` | `home/.config/nvim/lazyvim.json` | `~/.config/nvim/lazyvim.json` |
| `nvim` | `home/.config/nvim/lua/plugins/colorscheme.lua` | `~/.config/nvim/lua/plugins/colorscheme.lua` |
| `nvim` | `home/.config/nvim/lua/plugins/lint.lua` | `~/.config/nvim/lua/plugins/lint.lua` |
| `zellij` | `home/.config/zellij/config.kdl` | `~/.config/zellij/config.kdl` |
| `zellij` | `home/.config/zellij/layouts/dev.kdl` | `~/.config/zellij/layouts/dev.kdl` |
| `ghostty` | `home/.config/ghostty/config` | `~/.config/ghostty/config` |
| `fish` | `home/.config/fish/conf.d/homebrew-path.fish` | `~/.config/fish/conf.d/homebrew-path.fish` |
| `fish` | `home/.config/fish/conf.d/sdkroot.fish` | `~/.config/fish/conf.d/sdkroot.fish` |
| `markdownlint` | `home/.markdownlint-cli2.yaml` | `~/.markdownlint-cli2.yaml` |

App names come from the file path. `~/.config/<app>/...` names itself; anything
else needs a case in `app_for()` in `install.sh` (`claude-code`, `markdownlint`,
`git` are already mapped there).

Only customized files are tracked — install the [LazyVim
starter](https://www.lazyvim.org/installation) first, then run `install.sh` to
overlay these on top. Plugin versions are not pinned; `lazy-lock.json` stays
untracked.

## Shell

- shell: [fish](https://fishshell.com) — `sudo apt install fish` / `brew install fish`
- plugin manager: [fisher](https://github.com/jorgebucaran/fisher)
- nvm: [nvm.fish](https://github.com/jorgebucaran/nvm.fish)
- theme: [tide](https://github.com/IlanCosman/tide)
- font: [UbuntuMono Nerd Font](https://www.nerdfonts.com/) — `./install.sh fonts`

Only drop-ins this repo owns are tracked — `config.fish` and the fisher-managed
files in `conf.d/` (`_tide_init.fish`, `nvm.fish`) stay untracked. fish sources
everything in `conf.d/` automatically, so a snippet needs no wiring in
`config.fish`.

`conf.d/homebrew-path.fish` puts `/opt/homebrew/bin` directly before
`/usr/bin`. macOS runs `path_helper` for login shells, which appends the
`/etc/paths.d` entries — Homebrew's among them — *after* `/usr/bin`, so every
name Homebrew shares with an Apple one loses. `brew install python3` lands 3.14
in `/opt/homebrew/bin` and `python3` still resolves to Apple's frozen 3.9.6;
brew itself warns about it:

```
The following python@3.14 executables are shadowed by other commands
earlier in your PATH:
  pip3 (shadowed by /usr/bin/pip3)
  python3 (shadowed by /usr/bin/python3)
```

`brew shellenv` fixes this by prepending to the very front, which would also put
Homebrew ahead of `$fish_user_paths` and the nvm bin — so a later
`brew install node` would quietly shadow the nvm-managed one, the same bug in
the other direction. Inserting before `/usr/bin` beats the system copies and
leaves every user-managed tool where it is. Apple's copies stay put, so macOS
internals calling `/usr/bin/python3` by absolute path are unaffected.

It edits `$PATH` directly rather than going through `$fish_user_paths`, which is
a *universal* variable here — a global of that name would shadow it and silently
drop the paths it holds.

`conf.d/sdkroot.fish` pins `SDKROOT` to the Command Line Tools `MacOSX.sdk`
symlink on macOS, and does nothing elsewhere. clang otherwise picks the
*highest-numbered* SDK it finds rather than the one that symlink points at, so
a leftover SDK from a beta CLT wins over the one matching the installed
toolchain and every native build fails at the link step:

```
ld: tapi error: malformed file
.../MacOSX27.0.sdk/usr/lib/libSystem.B.tbd: unknown architecture
                   arm64e.x1-macos, arm64e.x1-maccatalyst ]
```

That hits tree-sitter parsers (`:TSInstall` reports only "Failed to compile
parser"), node native modules, cgo and Rust `cc-rs` alike. Targeting the
symlink rather than a pinned version keeps working across CLT upgrades. It only
reaches programs started from fish, though — deleting the stray SDK is the
complete fix:

```
sudo rm -rf /Library/Developer/CommandLineTools/SDKs/MacOSX<n>.sdk
```

## AI

- Claude Code
- Official plugins:
  - frontend-design
  - gopls-lsp
  - typescript-lsp
- Unofficial plugins:
  - [claude-notifications-go](https://github.com/777genius/claude-notifications-go)
  - [cc-skills-golang](https://github.com/samber/cc-skills-golang)
  - [mattpocock/skills](https://github.com/mattpocock/skills)
  - [ponytail](https://github.com/dietrichgebert/ponytail)

### Notable Skills And Tools
  - [ui-ux-pro-max](https://www.skills.sh/nextlevelbuilder/ui-ux-pro-max-skill/ui-ux-pro-max)
  - [ccstatusline](https://github.com/sirmalloc/ccstatusline)
  - [rtk](https://github.com/rtk-ai/rtk)

## Editor

- Mainly: nvim + [LazyVim](https://www.lazyvim.org)
- Sometimes: VS Code for better Farsi text rendering

LazyVim extras enabled: `editor.harpoon2`, `lang.go`, `lang.markdown`.
Colorscheme is gruvbox (hard contrast); nvim-lint points markdownlint-cli2 at
`~/.markdownlint-cli2.yaml`.

## Terminal Emulator

[Ghostty](https://ghostty.org/) — `brew install --cask ghostty` on macOS.

Config lives at `home/.config/ghostty/config`. Note the filename: Ghostty only
reads `config`, with no extension — a `config.ghostty` sitting next to it is
silently ignored.

`command` is what actually picks the shell — `shell-integration = fish` only
selects which integration script gets injected, so on its own it leaves Ghostty
starting the login shell from `/etc/passwd` (zsh here). `--login` keeps fish's
login-only setup running.

`font-family = UbuntuMono Nerd Font` is the monospace Ubuntu face from the Nerd
Fonts `UbuntuMono` release — the plain `Ubuntu` release is proportional and
misaligns in a terminal. `font-size = 15` is two steps up from Ghostty's
default 13.

`macos-option-as-alt = true` makes Option behave as Alt. On top of that,
Ghostty's default `alt+arrow_left`/`alt+arrow_right` binds send `esc:b`/`esc:f`,
which zellij reads as `Alt b`/`Alt f` — and `Alt f` is bound to
`ToggleFloatingPanes`. Both are unbound so the arrows reach zellij as
`Alt left`/`Alt right` for pane focus instead.

Word navigation in the shell then needs the raw sequences bound by hand:

```
bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word
```

## Multiplexer

[zellij](https://zellij.dev) — `brew install zellij` on macOS.

Custom keybinds built on `clear-defaults=true`, with locked mode as the resting
state (`Ctrl g` to leave it). A `dev` layout opens three tabs: nvim, claude, run.

```
zellij --layout dev
```

## Better Shell Experience

| Tool | Ubuntu | macOS |
| --- | --- | --- |
| [fd](https://github.com/sharkdp/fd) | `sudo apt install fd-find` | `brew install fd` |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `sudo apt install zoxide` | `brew install zoxide` |
| tree-sitter-cli | `sudo apt install tree-sitter-cli` | `brew install tree-sitter-cli` |
| [lazygit](https://github.com/jesseduffield/lazygit) | see repo releases | `brew install lazygit` |
| [fzf](https://junegunn.github.io/fzf/) | `sudo apt install fzf` | `brew install fzf` |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `sudo apt install ripgrep` | `brew install ripgrep` |
| [eza](https://github.com/eza-community/eza) | see repo install docs | `brew install eza` |
| [bat](https://github.com/sharkdp/bat) | `sudo apt install bat` (binary is `batcat`) | `brew install bat` |

On Ubuntu the `fd` binary is `fdfind` and `bat` is `batcat`; Homebrew installs
them under their real names.

Everything at once on macOS:

```
brew install fd zoxide tree-sitter-cli lazygit fzf ripgrep eza bat
```

## GNOME Extensions (Ubuntu only)

- [Internet Speed Meter](https://extensions.gnome.org/extension/3724/net-speed-simplified/)
