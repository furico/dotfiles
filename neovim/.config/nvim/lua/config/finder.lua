-- fuzzy finder（snacks.nvim の picker モジュール）。
-- ファイル検索・プロジェクト grep・バッファ/最近/ヘルプ/キーマップ/診断/
-- シンボルの導線を <leader>f（=find）名前空間で提供する。
--
-- snacks は多機能なスイートだが、ここでは picker だけを有効化する。他モジュール
-- （dashboard/notifier/scroll/indent 等）は setup に列挙せず既定の無効のまま保つ。
-- 純 Lua・build 不要・外部バイナリ不要（rg/fd があれば files/grep が速い）。
-- grep/files の実体は内部で ripgrep/fd を見つけて使うが、無くても起動は壊れない。
--
-- 未インストール（初回オフライン等）でも起動を壊さないよう pcall で保護する。
-- <leader>f=find のグループ名は which-key 側（ui.lua）で登録する。

local ok, snacks = pcall(require, "snacks")
if not ok then
  return
end

-- picker のみ有効化。他モジュールは書かない＝既定無効のまま。
snacks.setup({
  picker = { enabled = true },
})

-- キーマップは押下時に snacks.picker を遅延参照する。万一 picker が無い状態でも
-- 定義自体は無害で、押下してもエラーにしない。
local function pick(name)
  return function()
    local p = pcall(require, "snacks") and require("snacks").picker
    if p and type(p[name]) == "function" then
      p[name]()
    end
  end
end

local map = vim.keymap.set

map("n", "<leader>ff", pick("files"), { desc = "ファイルを検索" })
map("n", "<leader>fg", pick("grep"), { desc = "プロジェクトを grep" })
map("n", "<leader>fw", pick("grep_word"), { desc = "カーソル下の語で grep" })
map("n", "<leader>fb", pick("buffers"), { desc = "バッファを検索" })
map("n", "<leader>fr", pick("recent"), { desc = "最近開いたファイル" })
map("n", "<leader>fh", pick("help"), { desc = "ヘルプタグを検索" })
map("n", "<leader>fk", pick("keymaps"), { desc = "キーマップを検索" })
map("n", "<leader>fd", pick("diagnostics"), { desc = "診断を検索" })
map("n", "<leader>fs", pick("lsp_symbols"), { desc = "ドキュメントシンボル（LSP）" })
map("n", "<leader>fl", pick("resume"), { desc = "直前の picker を再開" })
