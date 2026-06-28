-- ファイラ（snacks.nvim の explorer モジュール）。サイドバーのツリーで
-- ディレクトリ構造の俯瞰・ファイル操作（作成/削除/改名/コピー/移動）を提供する。
-- explorer の有効化（enabled）と各種既定の採用は中央 setup（snacks.lua）が担う。
-- このモジュールはキーマップだけを持つ（setup は呼ばない）。
--
-- ツリー内のファイル操作キー（a 作成 / d 削除 / r 改名 / c コピー / m 移動、
-- h 折りたたみ / l 展開 等）は snacks.explorer の既定に委ね、ここでは再定義しない。
--
-- キーマップは押下時に snacks を遅延参照する。万一 explorer が無い状態でも
-- 定義自体は無害で、押下してもエラーにしない（finder.lua の遅延参照と同型）。

local map = vim.keymap.set

local function explorer(method)
  return function()
    local ok, snacks = pcall(require, "snacks")
    if not ok or not snacks.explorer then
      return
    end
    if method then
      snacks.explorer[method]()
    else
      snacks.explorer()
    end
  end
end

-- <leader>e/<leader>E は <leader>f=find 名前空間と衝突しない単独キー。
-- desc がそのまま which-key に出るためグループ登録（ui.lua）は不要。
map("n", "<leader>e", explorer(), { desc = "ファイラを開閉" })
map("n", "<leader>E", explorer("reveal"), { desc = "現在ファイルをファイラで表示" })
