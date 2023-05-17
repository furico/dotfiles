----------------------------------------
-- HELPERS
----------------------------------------
local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
local g = vim.g      -- a table to access global variables
local opt = vim.opt  -- to set options

local function map(mode, lhs, rhs, opts)
	local options = {noremap = true, silent = true}
	if opts then options = vim.tbl_extend('force', options, opts) end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

----------------------------------------
-- PLUGINS
----------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
require("lazy").setup({
	'hoob3rt/lualine.nvim',
	'rktjmp/lush.nvim',
	'ellisonleao/gruvbox.nvim',
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.1',
		dependencies = { 'nvim-lua/plenary.nvim' },
	},
	{
		'lewis6991/gitsigns.nvim',
		config = function()
			require('gitsigns').setup()
		end,
	},
	{
		'numToStr/Comment.nvim',
		config = function()
			require('Comment').setup()
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v2.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
		config = function()
			-- Unless you are still migrating, remove the deprecated commands from v1.x
			vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
		end,
	  },
})

----------------------------------------
-- OPTIONS
----------------------------------------
opt.termguicolors = true
opt.number = true
opt.hidden = true
opt.clipboard = 'unnamedplus'
opt.swapfile = false
opt.list = true
opt.listchars = 'eol:$,tab:>-,trail:~,extends:>,precedes:<'
opt.cmdheight = 2
opt.ignorecase = true
-- opt.ambiwidth = 'double'

----------------------------------------
-- UI
----------------------------------------
cmd('colorscheme gruvbox')
require('lualine').setup()

----------------------------------------
-- KEYMAPS
----------------------------------------
map('n', '<Leader>w', ':update<CR>')
map('n', '<Esc><Esc>', ':nohlsearch<CR>')
map('n', '<Esc><Esc>', ':nohlsearch<CR>')
map('n', '<C-n>', ':bn<CR>')
map('n', '<C-p>', ':bp<CR>')
map('n', '<Leader>d', ':bd<CR>')
map('n', '<Leader>dd', ':bd!<CR>')
map('n', '<Leader>11', ':qa!<CR>')

-- telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- nvim-tree
map('n', '<Leader>bf', ':Neotree<CR>')
map('n', '<Leader>bb', ':Neotree buffers<CR>')

----------------------------------------
-- nvim-tree
----------------------------------------
-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true
