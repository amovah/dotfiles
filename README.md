# dotfiles

My personal setup on Ubuntu.

## Install

Everything under `home/` mirrors `$HOME`. `install.sh` symlinks each file to its
matching path, backing up any existing real file as `<file>.backup`:

```
./install.sh --dry-run   # preview
./install.sh
```

Tracked configs:

| Repo path | Links to |
| --- | --- |
| `home/.config/zellij/config.kdl` | `~/.config/zellij/config.kdl` |
| `home/.config/zellij/layouts/dev.kdl` | `~/.config/zellij/layouts/dev.kdl` |
| `home/.config/nvim/lazyvim.json` | `~/.config/nvim/lazyvim.json` |
| `home/.config/nvim/lua/plugins/colorscheme.lua` | `~/.config/nvim/lua/plugins/colorscheme.lua` |
| `home/.config/nvim/lua/plugins/lint.lua` | `~/.config/nvim/lua/plugins/lint.lua` |
| `home/.markdownlint-cli2.yaml` | `~/.markdownlint-cli2.yaml` |

Only customized files are tracked — install the [LazyVim
starter](https://www.lazyvim.org/installation) first, then run `install.sh` to
overlay these on top. Plugin versions are not pinned; `lazy-lock.json` stays
untracked.

## Shell

- shell: [fish](https://fishshell.com)
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

[Ghostty](https://ghostty.org/)

Config:

```
font-family = "UbuntuMono Nerd Font"
font-size = 13
theme = Gruvbox Dark
command = fish

window-width = 220
window-height = 60
```

## Multiplexer

[zellij](https://zellij.dev)

Custom keybinds built on `clear-defaults=true`, with locked mode as the resting
state (`Ctrl g` to leave it). A `dev` layout opens three tabs: nvim, claude, run.

```
zellij --layout dev
```

## Better Shell Experience

- [fd](https://github.com/sharkdp/fd): `sudo apt install fd-find` (binary is `fdfind`)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- tree-sitter-cli: `sudo apt install tree-sitter-cli`
- [lazygit](https://github.com/jesseduffield/lazygit)
- [fzf](https://junegunn.github.io/fzf/)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [eza](https://github.com/eza-community/eza)
- [bat](https://github.com/sharkdp/bat)

## GNOME Extensions

- [Internet Speed Meter](https://extensions.gnome.org/extension/3724/net-speed-simplified/)
