source ~/.config/nvim/plugins.vim
luafile ~/.config/nvim/go-lsp.lua
luafile ~/.config/nvim/lsp-keybindings.lua
source ~/.config/nvim/autocompletion-config.vim
luafile ~/.config/nvim/lspsaga-config.lua
luafile ~/.config/nvim/theme-config.lua

" Theme
autocmd vimenter * ++nested colorscheme gruvbox

" formatting go files after saving
autocmd BufWritePre *.go lua vim.lsp.buf.formatting()
autocmd BufWritePre *.go lua goimports(1000)

source ~/.config/nvim/basics.vim
source ~/.config/nvim/telescope.vim
source ~/.config/nvim/nerdtree.vim
source ~/.config/nvim/buffers.vim
luafile ~/.config/nvim/bufferline.lua
luafile ~/.config/nvim/indent.lua

let delimitMate_expand_cr = 1

vnoremap <c-/> :TComment<cr>