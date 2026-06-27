## 1. plugins モジュールの作成

- [x] 1.1 `neovim/.config/nvim/lua/config/plugins.lua` を新設する
- [x] 1.2 短い src 記法用の薄いローカルヘルパ `gh(repo)`（完全な `https://github.com/` URL を返す）を定義する
- [x] 1.3 `vim.pack.add({...})` で検証用 colorscheme `tokyonight.nvim` を登録する
- [x] 1.4 `pcall(vim.cmd.colorscheme, "tokyonight")` で起動時に適用し、失敗時は `vim.notify(..., WARN)` でデフォルト続行する
- [x] 1.5 `local map = vim.keymap.set` 別名で `<leader>pu`（`vim.pack.update()`）と `<leader>ps`（`vim.pack.update(nil, { offline = true })`）を `desc` 付きで定義する

## 2. ローダ結線

- [x] 2.1 `neovim/.config/nvim/init.lua` の `require("config.lazy")` 予約コメントを除去する
- [x] 2.2 `require("config.plugins")` を `require("config.autocmds")` の後に追加する

## 3. 動作確認

- [x] 3.1 `nvim` を起動し、初回 clone が走って tokyonight が適用されることを確認する
- [x] 3.2 `~/.config/nvim/nvim-pack-lock.json`（= repo 内 `neovim/.config/nvim/nvim-pack-lock.json`）が生成されることを確認する
- [x] 3.3 `<leader>pu` で更新確認バッファ、`<leader>ps` でオフライン現状確認バッファが開くことを確認する
- [x] 3.4 colorscheme プラグインを一時退避した状態で起動し、エラーで止まらずデフォルト配色で続行することを確認する

## 4. Git 追跡とドキュメント

- [x] 4.1 生成された `nvim-pack-lock.json` を `git add` して追跡対象にする
- [x] 4.2 `neovim/README.md` の構成図・展開メモを更新する（`plugins.lua`、ロックファイルの扱いと手編集禁止、stow 反映、プラグイン実体は repo 外）
- [x] 4.3 `.stowrc` への ignore 追加が不要であることを確認する（ロックファイルは folded ディレクトリ内の生成実ファイルで stow リンク対象ではない）
