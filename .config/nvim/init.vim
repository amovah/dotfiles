" Language Server
source ~/.config/nvim/plugins.vim
luafile ~/.config/nvim/go-lsp.lua
luafile ~/.config/nvim/lsp-keybindings.lua
source ~/.config/nvim/autocompletion-config.vim
source ~/.config/nvim/cmp-nvim-lsp.lua

autocmd BufWritePre *.go lua goimports(1000)

" Theme
luafile ~/.config/nvim/theme-config.lua
autocmd vimenter * ++nested colorscheme gruvbox

" formatting go files after saving
" autocmd BufWritePre *.go lua vim.lsp.buf.formatting()
" autocmd BufWritePre *.go lua goimports(1000)

source ~/.config/nvim/basics.vim
source ~/.config/nvim/telescope.vim
source ~/.config/nvim/nerdtree.vim
source ~/.config/nvim/buffers.vim
luafile ~/.config/nvim/bufferline.lua
luafile ~/.config/nvim/indent.lua

vnoremap <c-/> :TComment<cr>
