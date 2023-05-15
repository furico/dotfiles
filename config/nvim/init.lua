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
	'hoob3rt/lualine.nvim';
	'rktjmp/lush.nvim';
	'ellisonleao/gruvbox.nvim',
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
