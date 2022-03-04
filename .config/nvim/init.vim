" basic config
source ~/.config/nvim/basics.vim

" parser
source ~/.config/nvim/plugins.vim

" neovim lsp - golang
luafile ~/.config/nvim/go-lsp.lua

" neovim lsp - plugins
luafile ~/.config/nvim/lsp-keybindings.lua
source ~/.config/nvim/autocompletion-config.vim
luafile ~/.config/nvim/cmp-nvim-lsp.lua

" auto format files
source ~/.config/nvim/auto-format-files.vim

" lsp saga
luafile ~/.config/nvim/lsp-saga.lua

" theme
luafile ~/.config/nvim/theme-config.lua

" treesitter - better grammer syntax highlighter
source ~/.config/nvim/treesitter.lua

" file finder
source ~/.config/nvim/telescope.vim

" file explorer
source ~/.config/nvim/nerdtree.vim

" buffers
source ~/.config/nvim/buffers.vim

" buffer line - bottom bar
luafile ~/.config/nvim/bufferline.lua

" indent guidance
luafile ~/.config/nvim/indent.lua

" git
luafile ~/.config/nvim/git.lua

vnoremap <c-/> :TComment<cr>
