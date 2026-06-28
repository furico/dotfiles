-- 編集 QoL。auto-pairs（mini.pairs）と surround（mini.surround）。
-- いずれも echasnovski の standalone リポジトリで、純 Lua・依存なし・build 不要。
-- 「編集 QoL」の対として1モジュールに両 setup を載せるが、片方が未導入でも
-- 他方を壊さないよう setup ごとに独立して pcall 保護する。
--
-- どちらも既定挙動のまま使う（キーや規則はカスタムしない）:
--   mini.pairs   … ( [ { " ' ` の auto-pair、<BS> でペア削除、<CR> でペア間改行。
--                  blink.cmp の default preset は <CR> を確定に使わない（確定は
--                  <C-y>）ため、補完と競合しない。
--   mini.surround … s* 既定マッピング（sa 追加 / sd 削除 / sr 置換 / sf・sF 検索 /
--                  sh ハイライト）。s=surround の which-key グループ名は ui.lua で登録。

-- ── auto-pairs（mini.pairs）─────────────────────────────
pcall(function()
  require("mini.pairs").setup({})
end)

-- ── surround（mini.surround）────────────────────────────
pcall(function()
  require("mini.surround").setup({})
end)
