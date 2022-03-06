" basic config
source ~/.config/nvim/basics.vim

" parser
source ~/.config/nvim/plugins.vim

" neovim lsp - golang
luafile ~/.config/nvim/go-lsp.lua

" neovim lsp - plugins
luafile ~/.config/nvim/lsp-keybindings.lua
source ~/.config/nvim/auto-completion.vim

" auto format files
source ~/.config/nvim/auto-format-files.vim

" lsp saga
luafile ~/.config/nvim/lsp-saga.lua

" theme
luafile ~/.config/nvim/theme-config.lua

" lua line - status line
luafile ~/.config/nvim/lualine.lua

" treesitter - better grammer syntax highlighter
source ~/.config/nvim/treesitter.lua

" file finder
" source ~/.config/nvim/telescope.vim
luafile ~/.config/nvim/telescope.lua

" file explorer
luafile ~/.config/nvim/nvim-tree.lua

" buffers (hotkeys)
source ~/.config/nvim/buffers.vim

" buffer (tab manager)
luafile ~/.config/nvim/bufferline.lua

" indent guidance
luafile ~/.config/nvim/indent.lua

" git
luafile ~/.config/nvim/git.lua
source ~/.config/nvim/lazygit.vim

" commnet
luafile ~/.config/nvim/comment.lua

" symbol outlines
luafile ~/.config/nvim/symbol-outline.lua

" which key
luafile ~/.config/nvim/which-key.lua

" trouble
luafile ~/.config/nvim/trouble.lua

" glow
source ~/.config/nvim/glow.vim