call plug#begin('~/.config/nvim/plugged')

" nvim lsp
Plug 'neovim/nvim-lspconfig'

" lsp auto complete
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'

" lsp saga
Plug 'tami5/lspsaga.nvim'

" finder
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" auto bracket closer
Plug 'raimondi/delimitmate'

" show buffers
Plug 'akinsho/bufferline.nvim'

" theme
Plug 'morhetz/gruvbox'
Plug 'joshdick/onedark.vim'

" buffers
Plug 'hoob3rt/lualine.nvim'
Plug 'ryanoasis/vim-devicons'

" nerdtree
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" comment
Plug 'tomtom/tcomment_vim'

" indent
Plug 'lukas-reineke/indent-blankline.nvim'

" Git
Plug 'tpope/vim-fugitive'
Plug 'lewis6991/gitsigns.nvim'

" tree sitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

call plug#end()
