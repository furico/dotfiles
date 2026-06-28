## 1. プラグイン登録

- [x] 1.1 `plugins.lua` の `vim.pack.add` に `echasnovski/mini.pairs` と `echasnovski/mini.surround` を追加する（`gh()` ヘルパ使用、`version` 省略 = default ブランチ、build フックなし）

## 2. editing モジュールの新設

- [x] 2.1 `lua/config/editing.lua` を新設し、`mini.pairs` と `mini.surround` をそれぞれ独立に `pcall(require, ...)` 保護したうえで `setup({})` を既定で呼ぶ（片方未導入でも他方を壊さない）
- [x] 2.2 `plugins.lua` の個別設定 require 群に `require("config.editing")` を追記する

## 3. which-key グループ登録

- [x] 3.1 `ui.lua` の `wk.add` に `{ "s", group = "surround" }` を追加する（既存の plugins/hunks/find グループに並べる）

## 4. 動作確認

- [x] 4.1 インサートで `(` `[` `{` `"` `'` を入力し、対応する閉じ側が自動補完されカーソルが内側に入ることを確認する
- [x] 4.2 ペア直後で `<BS>` が両側を削除し、ペア間で `<CR>` が改行＋インデントすることを確認する
- [x] 4.3 補完候補の表示中に `<CR>` を押し、誤確定されない（blink は `<C-y>` 確定）ことを確認する
- [x] 4.4 `saiw"` で単語を囲む / `sd"` で外す / `sr"'` で囲みを変えることを確認する
- [x] 4.5 `s` 押下で which-key に surround グループが `desc` 付きで出ること、片方未導入でも起動が壊れないことを確認する

## 5. ドキュメント

- [x] 5.1 `neovim/README.md` に編集 QoL の節（mini.pairs の auto-pair/`<BS>`/`<CR>` と blink 非競合、mini.surround の `s*` 既定キー、standalone 採用理由）を追加する
