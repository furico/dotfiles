-- UI レイヤ。colorscheme・statusline・インデントガイド・キーマップポップアップ。
-- いずれも純 Lua で build 不要。未導入でも起動を壊さないよう pcall で保護する。

-- ── colorscheme（catppuccin）─────────────────────────────
-- lualine の theme="auto" が追従できるよう、lualine setup より前に適用する。
-- flavour を変えるだけで mocha/macchiato/frappe/latte を切り替えられる。
local ok_cat, catppuccin = pcall(require, "catppuccin")
if ok_cat then
  catppuccin.setup({ flavour = "mocha" })
  if not pcall(vim.cmd.colorscheme, "catppuccin") then
    vim.notify("colorscheme 'catppuccin' を適用できませんでした（未インストール？）", vim.log.levels.WARN)
  end
end

-- ── statusline（lualine）─────────────────────────────────
-- theme="auto" で現在の colorscheme に追従。モード表示は lualine に一本化する。
pcall(function()
  require("lualine").setup({ options = { theme = "auto" } })
end)

-- 組み込みのモード表示（-- INSERT -- 等）は lualine と冗長なので消す。
vim.o.showmode = false

-- ── インデントガイド（indent-blankline v3 = ibl）─────────
pcall(function()
  require("ibl").setup({})
end)

-- ── キーマップポップアップ（which-key v3）────────────────
-- 既存マッピングの desc をそのまま拾う。<leader> 配下のグループ名だけ与える。
local ok_wk, wk = pcall(require, "which-key")
if ok_wk then
  wk.setup({})
  wk.add({
    { "<leader>p", group = "plugins" },
    { "<leader>h", group = "hunks" },
  })
end
