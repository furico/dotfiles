----------------------------------------
-- HELPERS
----------------------------------------
local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
local g = vim.g -- a table to access global variables
local opt = vim.opt -- to set options

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local function lsp_names()
  local clients = {}
  for _, client in ipairs(vim.lsp.get_active_clients { bufnr = 0 }) do
    table.insert(clients, client.name)
  end

  if #clients == 0 then
    return ""
  else
    return "󱘖 " .. table.concat(clients, ", ")
  end
end

----------------------------------------
-- PLUGINS
----------------------------------------
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
require("lazy").setup {
  {
    "hoob3rt/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lualine").setup {
        sections = {
          lualine_x = { lsp_names },
          lualine_y = { "encoding", "fileformat", "filetype" },
          lualine_z = { "progress", "location" },
        },
        tabline = {
          lualine_a = { { "filename", path = 1 } },
          lualine_z = { "tabs" },
        },
        extensions = {
          "neo-tree",
          "symbols-outline",
        },
      }
    end,
  },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.1",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
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
    keys = {
      { "<leader>bb", "<cmd>NeoTreeRevealToggle<cr>", desc = "NeoTreeRevealToggle" },
    },
    config = function()
      -- Unless you are still migrating, remove the deprecated commands from v1.x
      vim.cmd [[ let g:neo_tree_remove_legacy_commands = 1 ]]
      require("neo-tree").setup {
        window = {
          mappings = {
            ["e"] = function()
              vim.api.nvim_exec("Neotree focus filesystem left", true)
            end,
            ["b"] = function()
              vim.api.nvim_exec("Neotree focus buffers left", true)
            end,
            ["g"] = function()
              vim.api.nvim_exec("Neotree focus git_status left", true)
            end,
          },
        },
      }
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require "lspconfig"
      lspconfig.gopls.setup {}
      lspconfig.lua_ls.setup {
        settings = {
          Lua = {
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = { "vim" },
            },
          },
        },
      }
      -- goimports
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          vim.lsp.buf.code_action { context = { only = { "source.organizeImports" } }, apply = true }
        end,
      })
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          vim.lsp.buf.format()
        end,
      })
    end,
  },
  "hrsh7th/nvim-cmp", -- Autocompletion plugin
  "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
  "saadparwaiz1/cmp_luasnip", -- Snippets source for nvim-cmp
  "L3MON4D3/LuaSnip", -- Snippets plugin
  {
    "TimUntersberger/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    config = function()
      require("neogit").setup {
        integrations = {
          diffview = true,
        },
      }
    end,
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate", -- :MasonUpdate updates registry contents
    config = function()
      require("mason").setup()
    end,
  },
  "hashivim/vim-terraform",
  {
    "nvim-pack/nvim-spectre",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>S", '<cmd>lua require("spectre").open()<CR>', desc = "Open Spectre" },
      { "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', desc = "Search current word" },
      { "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', mode = "v", desc = "Search current word" },
      {
        "<leader>sp",
        '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
        desc = "Search on current file",
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup {
        show_current_context = true,
      }
      vim.cmd [[highlight IndentBlanklineChar guifg=#665c54 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineContextChar guifg=#d5c4a1 gui=nocombine]]
    end,
  },
  {
    "simrat39/symbols-outline.nvim",
    config = function()
      require("symbols-outline").setup()
    end,
  },
  {
    "dinhhuy258/git.nvim",
    config = function ()
      require('git').setup()
    end
  }
}

----------------------------------------
-- OPTIONS
----------------------------------------
opt.termguicolors = true
opt.number = true
opt.hidden = true
opt.clipboard = "unnamedplus"
opt.swapfile = false
opt.list = true
opt.listchars = "eol:$,tab:>-,trail:~,extends:>,precedes:<"
opt.cmdheight = 2
opt.ignorecase = true
opt.tabstop = 4
opt.shiftwidth = 4
-- opt.ambiwidth = 'double'

----------------------------------------
-- UI
----------------------------------------
cmd "colorscheme gruvbox"

----------------------------------------
-- KEYMAPS
----------------------------------------
map("n", "<Leader>w", ":update<CR>")
map("n", "<Esc><Esc>", ":nohlsearch<CR>")
map("n", "<Esc><Esc>", ":nohlsearch<CR>")
-- map('n', '<C-n>', ':bn<CR>')
-- map('n', '<C-p>', ':bp<CR>')
map("n", "<Leader>d", ":bd<CR>")
map("n", "<Leader>dd", ":bd!<CR>")
map("n", "<Leader>11", ":qa!<CR>")

-- telescope
local builtin = require "telescope.builtin"
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fc", builtin.commands, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

----------------------------------------
-- nvim-tree
----------------------------------------
-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

----------------------------------------
-- lsp-config
----------------------------------------
-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<space>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<space>f", function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

----------------------------------------
-- nvim-cmp
----------------------------------------
-- Add additional capabilities supported by nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local lspconfig = require "lspconfig"

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { "clangd", "rust_analyzer", "pyright", "tsserver" }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    -- on_attach = my_custom_on_attach,
    capabilities = capabilities,
  }
end

-- luasnip setup
local luasnip = require "luasnip"

-- nvim-cmp setup
local cmp = require "cmp"
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ["<C-u>"] = cmp.mapping.scroll_docs(-4), -- Up
    ["<C-d>"] = cmp.mapping.scroll_docs(4), -- Down
    -- C-b (back) C-f (forward) for snippet placeholder navigation.
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
  },
}
