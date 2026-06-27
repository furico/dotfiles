## 1. UI モジュール（colorscheme + lualine + ibl + which-key）

- [x] 1.1 `neovim/.config/nvim/lua/config/ui.lua` を新設する
- [x] 1.1a `ui.lua` 先頭で `require("catppuccin").setup({ flavour = "mocha" })` → `pcall(vim.cmd.colorscheme, "catppuccin")` を呼び、失敗時は WARN 通知でデフォルト継続する（lualine setup より前）
- [x] 1.2 `require("lualine").setup({ options = { theme = "auto" } })` を `pcall` 保護で呼ぶ
- [x] 1.3 `vim.o.showmode = false` を設定する
- [x] 1.4 `require("ibl").setup({})` を `pcall` 保護で呼ぶ（v3 モジュール名 `ibl`）
- [x] 1.5 `require("which-key").setup({})` を `pcall` 保護で呼び、`<leader>p`=plugins / `<leader>h`=hunks のグループ名を v3 の現行 API（実装直前に README 確認）で登録する

## 2. git モジュール（gitsigns）

- [x] 2.1 `neovim/.config/nvim/lua/config/git.lua` を新設する
- [x] 2.2 `require("gitsigns").setup({ on_attach = ... })` を `pcall` 保護で呼ぶ
- [x] 2.3 `on_attach` 内で `]c`/`[c` の hunk ナビ（diff モード時は組み込みへフォールバック）を `desc` 付き・`{ buffer = bufnr }` で定義する
- [x] 2.4 `on_attach` 内で `<leader>h` 系の hunk 操作（stage / reset / preview、stage/reset buffer、blame line、toggle 等）を `desc` 付き・バッファローカルで定義する

## 3. レジストリ結線とコメント更新

- [x] 3.1 `plugins.lua` の `vim.pack.add` に catppuccin（`name="catppuccin"`）/ lualine.nvim / which-key.nvim / gitsigns.nvim / indent-blankline.nvim を追加する（version 省略 = default ブランチ）
- [x] 3.1a `plugins.lua` から tokyonight の registry エントリと tokyonight 適用ブロック（`pcall(vim.cmd.colorscheme, "tokyonight")` …）を削除する
- [x] 3.2 `plugins.lua` 末尾で `require("config.ui")` → `require("config.git")` を読み込む
- [x] 3.3 `options.lua` の `showmode` 予約コメントを「ui.lua で false 設定済み」に更新する

## 4. 動作確認

- [x] 4.1 `nvim` を起動し、プラグインの clone が走ることを確認する
- [x] 4.1a colorscheme が `catppuccin` になっていること（`vim.g.colors_name`）、tokyonight が registry/lockfile から消えていることを確認する
- [x] 4.2 lualine の statusline が表示され（theme が catppuccin に追従）、`showmode=false` で組み込みモード表示が消えていることを確認する
- [x] 4.3 インデントのあるファイルで縦ガイド（ibl）が表示されることを確認する
- [x] 4.4 `<leader>` を押して which-key ポップアップが出ること、`<leader>p`/`<leader>h` にグループ名が付くことを確認する
- [x] 4.5 git 管理下のファイルで sign 列に変更が出ること、`]c`/`[c` ナビと `<leader>h` 操作・blame が効くことを確認する
- [x] 4.6 プラグイン未導入を模した状態でも起動が壊れないこと（pcall 保護）を確認する

## 5. ロックファイルとドキュメント

- [x] 5.1 ロックファイル `nvim-pack-lock.json` に新規プラグインの revision が追記され、tokyonight が削除されたことを確認し `git add` する
- [x] 5.2 `neovim/README.md` を更新する（colorscheme=catppuccin と tmux テーマ揃えの意図、lualine + showmode、ibl、which-key グループ、gitsigns の sign/hunk キーマップ、build 不要・default ブランチ。プラグイン管理の節の tokyonight 記述も catppuccin に更新）
