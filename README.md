# dotfiles

My personal setup on Ubuntu. `install.sh` also runs on macOS; the package
commands below list both.

## Install

Everything under `home/` mirrors `$HOME`. `install.sh` symlinks each file to its
matching path, backing up any existing real file as `<file>.backup`. Files are
grouped by the app they configure, and you install whole apps:

```
./install.sh                  # pick apps from a menu
./install.sh zellij nvim      # install named apps
./install.sh --all            # every app, no prompt
./install.sh --dry-run        # preview, changes nothing (combines with the above)
```

The menu uses [fzf](https://junegunn.github.io/fzf/) when it is installed
(`up`/`down` to move, `tab` to toggle, `ctrl-a` for all, `ctrl-d` for none,
`enter` to confirm, `esc` to cancel), and falls back to a numbered prompt
otherwise (`1 3-5`, `a` for all, `q` to quit). Either way each row shows how
many of that app's files are already linked:

```
  1) nvim         [      ] 3 files
  2) zellij       [      ] 2 files
  3) markdownlint [linked] 1 file
```

With no terminal attached it installs everything, so it stays usable from
another script.

Tracked configs:

| App | Repo path | Links to |
| --- | --- | --- |
| `nvim` | `home/.config/nvim/lazyvim.json` | `~/.config/nvim/lazyvim.json` |
| `nvim` | `home/.config/nvim/lua/plugins/colorscheme.lua` | `~/.config/nvim/lua/plugins/colorscheme.lua` |
| `nvim` | `home/.config/nvim/lua/plugins/lint.lua` | `~/.config/nvim/lua/plugins/lint.lua` |
| `zellij` | `home/.config/zellij/config.kdl` | `~/.config/zellij/config.kdl` |
| `zellij` | `home/.config/zellij/layouts/dev.kdl` | `~/.config/zellij/layouts/dev.kdl` |
| `ghostty` | `home/.config/ghostty/config` | `~/.config/ghostty/config` |
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
- font: [Ubuntu Nerd Font](https://www.nerdfonts.com/)

## AI

- Claude Code
- Official plugins:
  - frontend-design
  - gopls-lsp
  - typescript-lsp
  - superpowers
- Unofficial plugins:
  - [caveman](https://getcaveman.dev/)
  - [claude-mem](https://github.com/thedotmack/claude-mem)
  - [claude-notifications-go](https://github.com/777genius/claude-notifications-go)
  - [cc-skills-golang](https://github.com/samber/cc-skills-golang)

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
