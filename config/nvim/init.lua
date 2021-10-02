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
require 'paq' {
	'savq/paq-nvim';                  -- Let Paq manage itself
	'hoob3rt/lualine.nvim';
	'rktjmp/lush.nvim';
	'ellisonleao/gruvbox.nvim';
}

----------------------------------------
-- OPTIONS
----------------------------------------
g.mapleader = ' '
opt.number = true
opt.hidden = true
opt.clipboard = 'unnamedplus'
opt.swapfile = false
opt.list = true
opt.listchars = 'eol:$,tab:>-,trail:~,extends:>,precedes:<'

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
