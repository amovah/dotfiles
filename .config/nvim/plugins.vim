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
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

" auto bracket closer
Plug 'raimondi/delimitmate'

" show buffers
Plug 'akinsho/bufferline.nvim'

" theme
Plug 'morhetz/gruvbox'
Plug 'joshdick/onedark.vim'
Plug 'ray-x/aurora'
Plug 'mhartington/oceanic-next'

" buffers
Plug 'hoob3rt/lualine.nvim'

" file explorer
Plug 'kyazdani42/nvim-web-devicons' " for file icons
Plug 'kyazdani42/nvim-tree.lua'

" comment
Plug 'numToStr/Comment.nvim'

" indent
Plug 'lukas-reineke/indent-blankline.nvim'

" Git
Plug 'tpope/vim-fugitive'
Plug 'lewis6991/gitsigns.nvim' " show changes in right of editor
Plug 'kdheepak/lazygit.nvim'

" tree sitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

call plug#end()
