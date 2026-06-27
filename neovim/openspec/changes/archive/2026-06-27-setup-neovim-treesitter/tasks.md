## 1. treesitter 設定モジュールの作成

- [x] 1.1 `neovim/.config/nvim/lua/config/treesitter.lua` を新設する
- [x] 1.2 対象言語テーブルを定義する（`lua, vim, vimdoc, query, bash, markdown, markdown_inline, json, yaml, toml, diff, gitcommit`、追加は1行）
- [x] 1.3 起動時に `require("nvim-treesitter").install(langs)` を非同期で呼び、欠けたパーサを冪等に補う
- [x] 1.4 `clear = true` の専用 augroup を用意し、`FileType`（対象言語）で `pcall(vim.treesitter.start)` によりハイライトを有効化する
- [x] 1.5 同 `FileType` コールバックで、ウィンドウローカルに `foldmethod=expr` / `foldexpr=vim.treesitter.foldexpr()` を、バッファローカルに実験的 `indentexpr` を設定する（indent は1箇所で on/off できるよう隔離）
- [x] 1.6 `foldlevelstart = 99` を設定し、開いた直後に折りたたまれないようにする
- [x] 1.7 `PackChanged` の autocmd を専用 augroup で登録し、`spec.name == "nvim-treesitter"` かつ kind が install/update のとき、必要なら `packadd` してから対象言語の install と `:TSUpdate` を走らせる

## 2. レジストリ結線

- [x] 2.1 `lua/config/plugins.lua` の `vim.pack.add` に `{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" }` を追加する
- [x] 2.2 `plugins.lua` の末尾で `require("config.treesitter")` する

## 3. 動作確認

- [x] 3.1 `nvim` を起動し、初回 clone とパーサのビルドが走ることを確認する（C コンパイラ前提）
- [x] 3.2 対象ファイル（例: lua / yaml / markdown）で treesitter ハイライトが付くことを確認する（`vim.treesitter.start` 後の状態）
- [x] 3.3 折りたたみ（`zc`/`zo`）が効き、開いた直後は全展開で表示されることを確認する
- [x] 3.4 実験的 indent の挙動を確認する（誤インデント時は 1.5 の隔離箇所で外せること）
- [x] 3.5 パーサを一時退避した状態で対象ファイルを開き、エラーで止まらずデフォルトハイライトで続行することを確認する（pcall 保護）
- [x] 3.6 再ソースしてもハイライト/PackChanged autocmd が二重登録されないことを確認する

## 4. ロックファイルとドキュメント

- [x] 4.1 ロックファイル `nvim-pack-lock.json` に nvim-treesitter の revision が追記されたことを確認し `git add` する
- [x] 4.2 `neovim/README.md` に treesitter の節を追記する（main ブランチ採用理由、build フック、C コンパイラ前提、言語の足し方、fold/indent の扱い）
