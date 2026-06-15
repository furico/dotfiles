## Context

`setup-neovim-options`（archive 済み）の design D6 で、`autoread` は値のみ設定し、外部変更を検知する `checktime` autocmd は「autocmd 回」へ分離すると宣言していた。本 change がその後続。`setup-neovim-keymaps` に続く3つ目の plugin-free 層であり、これを締めると次は lazy.nvim 導入（プラグイン時代の入口）へ進む。

環境は nvim 0.12.x。本命ユースケースは「tmux で隣のペインに AI Agent、nvim は開きっぱなしで裏からファイルを書き換えられる」運用。そのため autoread の実効化と「変更が取り込まれたことの可視化」が設計の中心テーマになる。

## Goals / Non-Goals

**Goals:**
- `autoread` を実際に機能させる（外部変更の自動リロード）。
- 外部変更が取り込まれたことをユーザーに分かるようにする（AI Agent 運用の安心感）。
- プラグイン非依存で完結する QoL autocmd を一通り揃え、plugin-free フェーズを締める。
- 再ソースしても壊れない（冪等な）autocmd 登録にする。

**Non-Goals:**
- 末尾空白の自動トリム（粒度の問題、D6 参照）。
- tmux 側の `focus-events` 設定（tmux パッケージ回の越境依存）。
- プラグイン依存の autocmd / filetype 対応（LSP・notify・フォーマッタ等）。

## Decisions

### D1: `clear = true` 付き augroup でグループ化

options.lua / keymaps.lua はグローバル設定なので再ソースしても壊れないが、autocmd は素で書くと再ソースのたびに二重登録される。`vim.api.nvim_create_augroup(name, { clear = true })` で包み、再ソース時に既存登録をクリアして冪等にする。小さなローカルヘルパ `augroup(name)` を置く。

### D2: checktime は案C（`FocusGained` / `TermClose` / `TermLeave`）、tmux 連携は先送り

`autoread` は Neovim が mtime を「見に行った瞬間」しかリロードしない。能動的に `:checktime` を叩く必要がある。当初メモ（D6）は `FocusGained` / `CursorHold` だったが、`CursorHold` は `updatetime=250` だとアイドル中ずっと発火し、大きなファイルや低速 FS で重い。LazyVim 現行に倣い「意味のある瞬間」だけに絞る: フォーカス復帰（`FocusGained`）・埋め込み端末コマンド終了（`TermClose`/`TermLeave`）。特殊バッファ（`buftype` が空でない等）では叩かない。

代替案: 案B（案C + `CursorHold`）→ 却下。focus-events 無しでも拾える保険になるが、本 change では軽さを優先し、focus 連携は tmux 回で正攻法に解決する。

越境依存: tmux ペイン間で `FocusGained` を効かせるには tmux 側 `set -g focus-events on` が要る。リポジトリに tmux パッケージはまだ無いため、tmux パッケージ回へ明示先送りする（伏線を一段送る）。

### D3: リロードを `FileChangedShellPost` で通知

AI Agent 運用では「勝手にリロードされた」より「エージェントがこのファイルを触った」と分かる方が安心。`FileChangedShellPost`（外部変更を Vim が処理した後）で `vim.notify(..., vim.log.levels.WARN)` を出す。静かなリロードに気づける可視化。

### D4: ヤンクハイライトは新 API `vim.hl.on_yank` を使う

`vim.highlight.on_yank` は 0.11+ で `vim.hl.on_yank` にリネーム（旧名は非推奨エイリアス）。0.12 環境なので新 API を使う。`TextYankPost` で呼ぶ。

### D5: 一時バッファの `q` 閉じは FileType autocmd でバッファローカルに

`q` はノーマルモードの「マクロ記録開始」という重要キー。グローバルに `q` = 閉じる にすると編集中マクロが使えず事故る。そこで `FileType`（`help`/`qf`/`man`/`checkhealth`）で、そのバッファに限定して `q` = `:close` を `{ buffer = event.buf }` で上書きする。プラグイン由来の filetype（`lspinfo`/`notify` 等）は導入時にリストへ足して育てる。今回は plugin-free で実在する4つで開始。

### D6: 末尾空白トリムは見送り（粒度の問題）

保存フックでの末尾トリムは「ファイル全体」が粒度になり、自分が触っていない既存の末尾空白行まで巻き込んで変更扱いにする。結果 diff・`git blame`・コンフリクトを汚す。正しい粒度（編集 hunk 単位 = gitsigns、言語ごとのフォーマッタ = conform.nvim）が手に入る回まで待つ。「やらない」ではなく「正しい道具が来るまで先送り」。

### D7: 保存時の親ディレクトリ作成は URI パスを除外

`BufWritePre` で `mkdir -p` 相当を行い、深いパスへの新規保存を楽にする。ただし `oil://` / `fugitive://` 等の擬似 URI バッファ名に対して実ディレクトリを作らないよう、`name:match("^%w+://")` 等で除外する。

### D8: カーソル位置復元は gitcommit / gitrebase を除外

`BufReadPost` で `'"`（最後のカーソル位置マーク）へ復帰する。ただしコミットメッセージ編集（`gitcommit`/`gitrebase`）では前回位置ではなく先頭にいたいので除外する。さらにマーク行がファイル行数を超えていないかをガードする。

## Risks / Trade-offs

- [focus-events 無し環境では checktime が tmux ペイン切替で発火しない] → 本 change の既知の限界。tmux パッケージ回で `focus-events on` を入れて解消する旨を明記。
- [`q` 上書きが一時バッファ内の別操作と競合する可能性] → 対象を読むだけの4 filetype に限定。プラグイン追加時に個別検討。
- [`FileType *` の formatoptions 調整が一部 ftplugin と競合] → autocmd は ftplugin の後に走るため上書きが効く。問題が出た filetype は個別に除外する余地を残す。
- [通知が頻繁だと煩い] → WARN レベル一行に留め、リロード時のみ。CursorHold を使わない案C なので過剰発火しない。

## Migration Plan

1. `neovim/.config/nvim/lua/config/autocmds.lua` を作成。
2. `neovim/.config/nvim/init.lua` に `require("config.autocmds")` を追加（options / keymaps の後）。
3. `nvim` を起動しエラーが出ないこと、各 autocmd が登録されることを確認。
4. 外部でファイルを書き換え → nvim にフォーカスを戻し、自動リロードと通知が出ることを確認。
5. ロールバック: `autocmds.lua` を削除し `init.lua` の require 行を戻す（または `stow -D neovim`）。

## Open Questions

- なし（イベント設計・通知・対象 filetype・見送り判断は探索フェーズで確定済み）。
