## 1. レジストリ登録

- [x] 1.1 `plugins.lua` の `vim.pack.add` に `folke/snacks.nvim` を追加する（`gh("folke/snacks.nvim")`、`version` 省略 = default ブランチ、UI/QoL 群のコメント節に並べる）

## 2. finder モジュール（snacks.picker）

- [x] 2.1 `neovim/.config/nvim/lua/config/finder.lua` を新設する（先頭コメントで役割・picker のみ有効化・build 不要・pcall 保護の方針を記す）
- [x] 2.2 実装直前に現物 README / `:h snacks-picker` で setup と picker API 名（`files`/`grep`/`grep_word`/`buffers`/`recent`/`help`/`keymaps`/`diagnostics`/`lsp_symbols`/`resume`）を確認する
- [x] 2.3 `require("snacks").setup({ picker = { enabled = true } })` を `pcall` 保護で呼び、未導入時は早期 return する（picker 以外のモジュールは列挙せず既定無効のまま）
- [x] 2.4 `<leader>f` 名前空間のキーマップ10個を `desc` 付き・遅延参照（`function() require("snacks").picker.X() end`）で定義する: `ff`=files / `fg`=grep / `fw`=grep_word / `fb`=buffers / `fr`=recent / `fh`=help / `fk`=keymaps / `fd`=diagnostics / `fs`=lsp_symbols / `fl`=resume
- [x] 2.5 `gd`/`grr` 等の LSP ナビ既定（neovim-lsp）を再定義していないことを確認する

## 3. 結線（plugins.lua / ui.lua）

- [x] 3.1 `plugins.lua` 末尾の require 群に `require("config.finder")` を追記する
- [x] 3.2 `ui.lua` の `wk.add` に `{ "<leader>f", group = "find" }` を1行追加する

## 4. 動作確認

- [x] 4.1 `nvim` を起動し snacks の clone が走ること、起動が壊れないことを確認する
- [x] 4.2 `<leader>ff`（files）・`<leader>fg`（grep）が開き、選択でファイルを開ける／一致行を絞れることを確認する
- [x] 4.3 `<leader>fb`/`fr`/`fh`/`fk`/`fd`/`fs`/`fw`/`fl` がそれぞれ対応 picker を開くことを確認する
- [x] 4.4 `<leader>` 押下で which-key に `<leader>f`=find グループ名と配下が `desc` 付きで出ることを確認する
- [x] 4.5 picker 以外の snacks モジュール（dashboard/notifier/scroll/indent 等）が動いていないこと、既存の UI/LSP/git 動作が不変なことを確認する
- [x] 4.6 snacks 未導入を模した状態でも起動が壊れない（pcall 保護）ことを確認する

## 5. ロックファイルとドキュメント

- [x] 5.1 ロックファイル `nvim-pack-lock.json` に snacks の revision が追記されたことを確認し `git add` する
- [x] 5.2 `neovim/README.md` に finder の節を追加する（snacks.picker、picker のみ有効化、`<leader>f` キーマップ一覧、build 不要・default ブランチ、which-key の find グループ）
