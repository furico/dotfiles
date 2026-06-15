## 1. autocmds モジュールの作成

- [x] 1.1 `neovim/.config/nvim/lua/config/autocmds.lua` を作成し、`clear = true` 付き augroup を返すローカルヘルパ `augroup(name)` を定義する
- [x] 1.2 autoread 実効化: `FocusGained` / `TermClose` / `TermLeave` で、特殊バッファ以外に対し `:checktime` を叩く
- [x] 1.3 リロード通知: `FileChangedShellPost` で「外部変更を取り込んだ」を `vim.notify`（WARN）で出す
- [x] 1.4 ヤンクハイライト: `TextYankPost` で `vim.hl.on_yank()` を呼ぶ
- [x] 1.5 カーソル位置復元: `BufReadPost` で前回位置へ復帰（`gitcommit`/`gitrebase` 除外、行数ガード）
- [x] 1.6 分割均等化: `VimResized` で現在タブを保持しつつ `wincmd =`
- [x] 1.7 一時バッファの `q` 閉じ: `FileType`（`help`/`qf`/`man`/`checkhealth`）でバッファローカルに `q` = `:close`
- [x] 1.8 親ディレクトリ自動作成: `BufWritePre` で不足ディレクトリを作成（`^%w+://` の URI パスは除外）
- [x] 1.9 コメント継続無効化: `FileType *` で `formatoptions` から `c`/`r`/`o` を除去

## 2. ローダへの組み込み

- [x] 2.1 `neovim/.config/nvim/init.lua` の `require("config.autocmds")` を有効化する（options / keymaps の後に読み込む）

## 3. 展開と検証

- [x] 3.1 `~/.config/nvim/lua/config/autocmds.lua` がリンク経由で参照されることを確認する（必要なら `stow -R neovim`）
- [x] 3.2 `nvim` を起動しエラーが出ないこと、autocmd が登録されていること（`:autocmd` 等）を確認する
- [x] 3.3 外部でファイルを書き換え → nvim にフォーカスを戻し、自動リロードと通知が出ることを確認する
- [x] 3.4 ヤンク時に範囲が一瞬ハイライトされることを確認する
- [x] 3.5 ファイルを開き直したときに前回のカーソル位置へ復帰することを確認する
- [x] 3.6 `:help` を開き `q` で閉じられることを確認する
- [x] 3.7 存在しない深いパスへ新規保存して親ディレクトリが作成されることを確認する
