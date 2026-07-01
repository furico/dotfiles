-- lazygit 連携（snacks.nvim の lazygit モジュール）。
-- neovim 内のフロートで lazygit を開く。lazygit でファイル上にカーソルを置いて
-- e（edit）を押すと、今使っている neovim の同じインスタンスにそのファイルが開くため、
-- lazygit で見た変更をそのまま全体閲覧・編集できる（差分の配色は git/.gitconfig の delta）。
--
-- snacks の setup（picker / explorer の有効化）は中央 snacks.lua が担う。
-- ここは lazygit のキーマップ（<leader>g 名前空間）だけを持つ薄い層にする。
-- 未インストール（初回オフライン等）でも起動を壊さないよう pcall で保護する。
-- <leader>g=git のグループ名は which-key 側（ui.lua）で登録する。

local ok = pcall(require, "snacks")
if not ok then
  return
end

-- 押下時に snacks.lazygit を遅延参照する。万一 snacks が無い状態でも
-- 定義自体は無害で、押下してもエラーにしない。
local function lazygit(method)
  return function()
    local s = pcall(require, "snacks") and require("snacks")
    if s and type(s.lazygit) == "table" and type(s.lazygit[method]) == "function" then
      s.lazygit[method]()
    end
  end
end

local map = vim.keymap.set

map("n", "<leader>gg", lazygit("open"), { desc = "lazygit を開く" })
map("n", "<leader>gf", lazygit("log_file"), { desc = "現在ファイルの履歴（lazygit）" })
map("n", "<leader>gl", lazygit("log"), { desc = "リポジトリの履歴（lazygit）" })
