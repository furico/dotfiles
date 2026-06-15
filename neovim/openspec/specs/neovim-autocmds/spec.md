# neovim-autocmds Specification

## Purpose

プラグインに依存しない Neovim の autocmd を定義する。中心は `neovim-options` で値のみ設定された `autoread` の実効化（外部変更の自動リロードと可視化）であり、加えてヤンクハイライト・カーソル位置復元・分割均等化・一時バッファの `q` 閉じ・保存時の親ディレクトリ作成・コメント継続無効化といった QoL を含む。`lua/config/autocmds.lua` に定義し、薄い `init.lua` ローダから `require` 経由で読み込む。

## Requirements

### Requirement: autocmds モジュールの読み込み

`init.lua` は `lua/config/autocmds.lua` を `require` 経由で読み込まなければならない（MUST）。読み込みは `require("config.options")` および `require("config.keymaps")` の後に行う。autocmd の実体定義は `init.lua` に直接書かず `autocmds.lua` に置く。

#### Scenario: autocmds モジュールが読み込まれる

- **WHEN** Neovim が起動し `init.lua` が評価される
- **THEN** options / keymaps に続いて `require("config.autocmds")` が評価される
- **AND** `autocmds.lua` で定義された autocmd が登録される

### Requirement: 冪等な autocmd 登録

autocmd は `clear = true` を指定した augroup でグループ化されなければならない（MUST）。これにより設定を再ソースしても二重登録されない。

#### Scenario: 再ソースで二重登録されない

- **WHEN** 設定を再ソースする（`:source` 等で `autocmds.lua` が再評価される）
- **THEN** 同一 augroup の既存 autocmd がクリアされてから再登録され、同じ autocmd が重複しない

### Requirement: autoread の実効化

外部で変更されたファイルを自動的に再読み込みするため、`FocusGained` / `TermClose` / `TermLeave` のいずれかで `:checktime` を実行しなければならない（MUST）。特殊バッファ（編集対象でないバッファ）では実行しない。`CursorHold` は使用しない（過剰発火を避けるため）。

#### Scenario: フォーカス復帰でリロードされる

- **WHEN** nvim の外（または別端末）でファイルが書き換えられ、その後 nvim にフォーカスが戻る（`FocusGained`）
- **THEN** `:checktime` が実行される
- **AND** バッファが未変更であれば `autoread` により内容が再読み込みされる

#### Scenario: 端末コマンド終了後にリロードされる

- **WHEN** 埋め込み端末のコマンドが終了する（`TermClose` / `TermLeave`）
- **THEN** `:checktime` が実行される

### Requirement: 外部変更リロードの通知

外部変更を取り込んだことをユーザーに通知しなければならない（MUST）。`FileChangedShellPost` で `vim.notify` を WARN レベルで出す。

#### Scenario: リロード時に通知が出る

- **WHEN** 外部変更が検知されバッファが再読み込みされる（`FileChangedShellPost`）
- **THEN** 外部変更を取り込んだ旨の通知が WARN レベルで表示される

### Requirement: ヤンクハイライト

ヤンクした範囲を一時的にハイライトしなければならない（MUST）。`TextYankPost` で `vim.hl.on_yank()` を呼ぶ（`vim.highlight.on_yank` ではなく現行 API を使う）。

#### Scenario: ヤンク範囲が光る

- **WHEN** テキストをヤンクする
- **THEN** ヤンクした範囲が一時的にハイライトされる

### Requirement: カーソル位置の復元

ファイルを開いたとき、前回の編集位置へカーソルを復帰しなければならない（MUST）。`BufReadPost` で最後のカーソル位置マークへ移動する。ただし `gitcommit` / `gitrebase` は除外し、マーク行がファイル行数を超える場合は復帰しない。

#### Scenario: 前回位置へ復帰する

- **WHEN** 以前編集したファイルを開き直す
- **THEN** カーソルが前回の位置へ移動する

#### Scenario: コミットメッセージは先頭のまま

- **WHEN** `gitcommit` / `gitrebase` のバッファを開く
- **THEN** カーソル位置の復元は行われない（先頭にとどまる）

### Requirement: 分割の均等化

端末（ウィンドウ）サイズ変更時に分割を均等化しなければならない（MUST）。`VimResized` で `wincmd =` を実行し、その際に現在のタブページを保持する。

#### Scenario: リサイズで分割が揃う

- **WHEN** 端末のサイズが変わる（`VimResized`）
- **THEN** 分割ウィンドウのサイズが均等化される
- **AND** 操作後も元のタブページにとどまる

### Requirement: 一時バッファを q で閉じる

一時的なバッファでは `q` で閉じられるようにしなければならない（MUST）。`FileType`（`help` / `qf` / `man` / `checkhealth`）で、そのバッファに限定（`buffer = event.buf`）して `q` を `:close` に割り当てる。`q` をグローバルに上書きしてはならない（マクロ記録を保つため）（MUST NOT）。

#### Scenario: ヘルプを q で閉じる

- **WHEN** `:help` などで対象 filetype のウィンドウを開き、normal モードで `q` を押す
- **THEN** そのウィンドウが閉じる

#### Scenario: 通常バッファの q は影響を受けない

- **WHEN** 通常のファイルバッファで `q` を押す
- **THEN** 標準のマクロ記録開始として動作する（上書きされていない）

### Requirement: 保存時の親ディレクトリ自動作成

存在しない親ディレクトリへ新規保存する際、ディレクトリを自動作成しなければならない（MUST）。`BufWritePre` で不足ディレクトリを作成する。ただし `oil://` 等の URI 形式（`^%w+://`）のバッファ名は除外する。

#### Scenario: 深いパスへ保存できる

- **WHEN** まだ存在しない親ディレクトリを含むパスへ新規ファイルを保存する
- **THEN** 親ディレクトリが作成され、保存が成功する

### Requirement: コメント継続の無効化

改行時にコメントリーダーが自動挿入されないようにしなければならない（MUST）。`FileType *` で `formatoptions` から `c` / `r` / `o` を除去する。

#### Scenario: コメント行で改行してもコメントが継続しない

- **WHEN** コメント行で `o` や改行を行う
- **THEN** 新しい行に自動でコメントリーダーが挿入されない

### Requirement: スコープ外項目の非導入

本 change ではプラグイン非依存の autocmd のみを扱い、以下を導入してはならない（MUST NOT）。これらは別の手段・別 change で扱う。

#### Scenario: 今回入れない項目

- **WHEN** 本 change の成果物を確認する
- **THEN** 末尾空白の自動トリムは含まれない（diff / `git blame` を汚すため、gitsigns / conform.nvim 等の粒度が得られる回へ先送り）
- **AND** tmux 側の `focus-events` 設定は含まれない（tmux パッケージ回の越境依存）
- **AND** プラグイン由来の filetype（`lspinfo` / `notify` 等）の `q` 閉じ対象や、プラグイン依存の autocmd は含まれない
