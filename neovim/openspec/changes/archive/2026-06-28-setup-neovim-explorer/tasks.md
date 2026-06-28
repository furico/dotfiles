## 1. snacks.setup の中央集約

- [x] 1.1 `lua/config/snacks.lua` を新設し、`pcall(require, "snacks")` 保護のうえ `snacks.setup({ picker = { enabled = true }, explorer = { enabled = true } })` を1か所に置く（未導入時は early return）
- [x] 1.2 `finder.lua` から自前の `snacks.setup({ picker = { enabled = true } })` 呼び出しを除去し、`pick()` ヘルパと `<leader>f` キーマップ群だけを残す（snacks 未導入時の早期 return は維持）

## 2. explorer モジュールの新設

- [x] 2.1 `lua/config/explorer.lua` を新設し、`pcall(require, "snacks")` 保護のうえ `<leader>e`=`require("snacks").explorer()`（開閉）、`<leader>E`=`require("snacks").explorer.reveal()`（現在ファイル表示）を `desc` 付きで定義する。setup は呼ばない
- [x] 2.2 キーマップは押下時に snacks を遅延参照し、未導入時もエラーにならない形にする（finder.lua の遅延参照と同型）

## 3. 結線

- [x] 3.1 `plugins.lua` の個別設定 require 群を `require("config.snacks")` → `require("config.finder")` → `require("config.explorer")` の順に整える（`vim.pack.add` レジストリは変更しない）

## 4. 動作確認

- [x] 4.1 Neovim を再起動し、`<leader>e` でサイドバーが開閉、`<leader>E` で現在ファイルがツリー内に展開・選択されることを確認する
- [x] 4.2 既存の finder（`<leader>ff`/`<leader>fg` 等）が従来通り動作することを確認する（setup 移管の回帰チェック）
- [x] 4.3 `nvim <ディレクトリ>` で netrw ではなく snacks.explorer が開くこと（`replace_netrw` 既定）を確認する
- [x] 4.4 ツリー内で `d` 削除がゴミ箱送りになること（`trash` 既定・`trash` コマンド導入済み）を確認する
- [x] 4.5 `:checkhealth snacks` で explorer 関連の警告が無いことを確認する

## 5. ドキュメント

- [x] 5.1 `neovim/README.md` に explorer の節（`<leader>e`/`<leader>E`、ツリー内主要キー、`replace_netrw`/`trash` 既定）を追加する
