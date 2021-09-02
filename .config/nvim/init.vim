source ~/.config/nvim/plugins.vim
source ~/.config/nvim/basics.vim
"luafile ~/.config/nvim/go-lsp.lua
"luafile ~/.config/nvim/lsp-keybindings.lua
"source ~/.config/nvim/autocompletion-config.vim
"luafile ~/.config/nvim/lspsaga-config.lua
"luafile ~/.config/nvim/lspkind-nvim.lua
source ~/.config/nvim/coc-setup.vim
luafile ~/.config/nvim/theme-config.lua

" Theme
autocmd vimenter * ++nested colorscheme gruvbox

" formatting go files after saving
"autocmd BufWritePre *.go lua vim.lsp.buf.formatting()
"autocmd BufWritePre *.go lua goimports(1000)

source ~/.config/nvim/telescope.vim
source ~/.config/nvim/nerdtree.vim
"luafile ~/.config/nvim/nvim-tree.lua
source ~/.config/nvim/buffers.vim
luafile ~/.config/nvim/bufferline.lua
luafile ~/.config/nvim/indent.lua

vnoremap <c-/> :TComment<cr>
