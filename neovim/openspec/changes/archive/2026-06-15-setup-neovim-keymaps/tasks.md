## 1. keymaps モジュールの作成

- [x] 1.1 `neovim/.config/nvim/lua/config/keymaps.lua` を作成し、`local map = vim.keymap.set` を定義する
- [x] 1.2 Tier 1: `<Esc>`（normal）に `<cmd>nohlsearch<CR>` を割り当てる（`desc` 付き）
- [x] 1.3 Tier 1: ウィンドウ移動 `<C-h/j/k/l>`（normal）を `<C-w>h/j/k/l` に割り当てる（各 `desc` 付き）
- [x] 1.4 Tier 1: ターミナル離脱 `<Esc><Esc>`（terminal モード）を `<C-\><C-n>` に割り当てる（`desc` 付き）
- [x] 1.5 Tier 2: ビジュアル（`x` モード）の `<` / `>` を `<gv` / `>gv` に割り当てる（`desc` 付き）
- [x] 1.6 Tier 2: `n` / `N`（normal）を `nzzzv` / `Nzzzv` に割り当てる（`desc` 付き）

## 2. ローダへの組み込み

- [x] 2.1 `neovim/.config/nvim/init.lua` の `require("config.keymaps")` を有効化する（options の後に読み込む）

## 3. 展開と検証

- [x] 3.1 `~/.config/nvim/lua/config/keymaps.lua` がリンク経由で参照されることを確認する（必要なら `stow -R neovim` で再展開）
- [x] 3.2 `nvim` を起動しエラーが出ないことを確認する
- [x] 3.3 ウィンドウ分割して `<C-h/j/k/l>` で移動できることを確認する
- [x] 3.4 検索後に `<Esc>` でハイライトが消えることを確認する
- [x] 3.5 ビジュアル選択で `>` を連打しても選択が維持されること、`n`/`N` 後にカーソル行が中央へ来ることを確認する
- [x] 3.6 ターミナル（`:terminal`）で `<Esc><Esc>` がノーマルモードへ抜けることを確認する
