-- snacks.nvim の中央 setup。snacks の各モジュール（picker / explorer …）は
-- 単一の snacks.setup を共有するため、setup はこのモジュールに1か所だけ置く。
-- 各 capability（finder.lua / explorer.lua）は自分のキーマップだけを持つ薄い層にし、
-- plugins.lua では snacks（setup）→ 各 capability（keymap）の順に require する。
--
-- 有効化するのは picker と explorer のみ。dashboard / notifier / scroll / indent 等の
-- 他モジュールは列挙せず既定の無効のまま保つ。
-- 未インストール（初回オフライン等）でも起動を壊さないよう pcall で保護する。

local ok, snacks = pcall(require, "snacks")
if not ok then
  return
end

snacks.setup({
  -- fuzzy finder。キーマップは finder.lua（<leader>f 名前空間）。
  picker = { enabled = true },
  -- ファイラ。キーマップは explorer.lua（<leader>e/<leader>E）。
  -- explorer は picker の上に構築され、replace_netrw=true・trash=true や
  -- tree/git_status/diagnostics/follow_file/sidebar レイアウトなどの既定をそのまま採用する。
  explorer = { enabled = true },
})
