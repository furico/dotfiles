## Why

`setup-neovim-options` で `autoread` の値だけ置き、その実効化（外部変更を検知する `checktime` autocmd）は「autocmd 回のスコープ」として明示的に先送りしていた（options design D6）。本 change はその伏線を回収し、プラグイン非依存で完結する autocmd 層を整える。これにより「素の Neovim を快適に使う」フェーズを締め、次のプラグイン管理（lazy.nvim）導入回へ進める土台を作る。`init.lua` には既に `require("config.autocmds")` の置き場所がコメントで予約されている。

## What Changes

- `lua/config/autocmds.lua` を新設し、プラグイン非依存の autocmd を定義する。
- `init.lua` のコメントアウトされた `require("config.autocmds")` を有効化する。
- 再ソースしても二重登録されないよう、`clear = true` 付きの augroup でグループ化する。
- 追加する autocmd:
  - **autoread 実効化**: `FocusGained` / `TermClose` / `TermLeave` で `:checktime` を叩く（案C）。tmux ペイン間の `focus-events` 連携は将来の tmux パッケージ回へ先送り。
  - **外部変更リロードの通知**: `FileChangedShellPost` で「外部変更を取り込んだ」を `vim.notify`（WARN）で知らせる。
  - **ヤンクハイライト**: `TextYankPost` で `vim.hl.on_yank()`。
  - **カーソル位置復元**: `BufReadPost` で前回位置へ復帰（`gitcommit`/`gitrebase` は除外、行数ガードあり）。
  - **分割の均等化**: `VimResized` で現在タブを保持しつつ `wincmd =`。
  - **一時バッファを `q` で閉じる**: `FileType`（`help`/`qf`/`man`/`checkhealth`）でバッファローカルに `q` = `:close`。
  - **保存時の親ディレクトリ自動作成**: `BufWritePre` で不足ディレクトリを作成（`oil://` 等の URI パスは除外）。
  - **コメント継続の無効化**: `FileType *` で `formatoptions` から `c`/`r`/`o` を除去。
- 今回のスコープに**含めない**もの:
  - 末尾空白の自動トリム。保存フックでやると粒度が「ファイル全体」になり、無関係な行まで巻き込んで diff / `git blame` を汚す。編集行単位やフォーマッタの粒度が手に入る回（gitsigns / conform.nvim）へ先送りする。
  - tmux 側の `focus-events on` 設定（tmux パッケージ回で扱う越境依存）。
  - プラグイン由来の filetype（`lspinfo`/`notify` 等）の `q` 閉じ対象への追加。導入時に育てる。

## Capabilities

### New Capabilities
- `neovim-autocmds`: プラグイン非依存の autocmd 群（autoread 実効化と通知・ヤンクハイライト・カーソル復元・分割均等化・一時バッファの `q` 閉じ・保存時の親ディレクトリ作成・コメント継続無効化）と、それを読み込む `init.lua` ローダ更新。

### Modified Capabilities
<!-- なし。neovim-options の autoread は「値のみ設定」のままで要件変更はなく、本 change はその実効化を新 capability として追加する。 -->

## Impact

- 新規ファイル: `neovim/.config/nvim/lua/config/autocmds.lua`。
- 変更ファイル: `neovim/.config/nvim/init.lua`（`require("config.autocmds")` の行を追加）。
- `~/.config/nvim` はディレクトリ単位のシンボリックリンクのため、新規ファイルは `stow -R` なしで反映される。
- 越境依存（先送り）: checktime 案C の `FocusGained` を tmux ペイン間で効かせるには、将来の tmux パッケージで `set -g focus-events on` が必要。
- 既存パッケージ（vim, zsh）および neovim-options / neovim-keymaps の要件への影響なし。
