# neovim-options Specification

## Purpose

Neovim の基本オプション設定を GNU Stow + XDG Base Directory 仕様に従って管理し、薄い `init.lua` ローダ経由で `lua/config/options.lua` を読み込む構成を定義する。

## Requirements

### Requirement: stow パッケージ構成と XDG 配置

`neovim` パッケージは GNU Stow で XDG Base Directory 仕様に従った配置で展開されなければならない（MUST）。設定ファイルは `neovim/.config/nvim/` 配下に置き、`stow neovim` 実行時に `~/.config/nvim/` 配下へシンボリックリンクされる。

#### Scenario: stow でリンクが作成される

- **WHEN** リポジトリルートで `stow neovim` を実行する
- **THEN** `~/.config/nvim/init.lua` が `neovim/.config/nvim/init.lua` へのシンボリックリンクとして作成される
- **AND** `~/.config/nvim/lua/config/options.lua` が対応する実体へリンクされる

#### Scenario: openspec ディレクトリはリンクされない

- **WHEN** `stow neovim` を実行する
- **THEN** `neovim/openspec/` はリポジトリルートの `.stowrc`（`--ignore=openspec`）により対象外となり、ホーム配下にリンクされない

### Requirement: 薄い init.lua ローダ

`init.lua` は設定の読み込み順を決めるだけの薄いローダでなければならない（MUST）。オプションの実体定義を直接書かず、`lua/config/` 配下のモジュールを `require` する。今回のスコープでは `require("config.options")` のみを行う。

#### Scenario: options モジュールが読み込まれる

- **WHEN** Neovim が起動し `init.lua` が評価される
- **THEN** `lua/config/options.lua` が `require` 経由で読み込まれ、定義されたオプションが反映される

#### Scenario: 将来のモジュール追加に耐える構成

- **WHEN** 将来 `keymaps.lua` や `autocmds.lua` を追加する
- **THEN** `init.lua` に `require` 行を追加するだけで拡張でき、既存の options 読み込みに影響を与えない

### Requirement: leader キー設定

leader キーはプラグイン読み込み前に設定されなければならない（MUST）。`mapleader` をスペース、`maplocalleader` をバックスラッシュに設定する。

#### Scenario: leader が設定される

- **WHEN** Neovim 起動後に leader を確認する
- **THEN** `mapleader` が `" "`（スペース）に設定されている
- **AND** `maplocalleader` が `"\"`（バックスラッシュ）に設定されている

### Requirement: 基本オプション設定

`lua/config/options.lua` は以下の基本オプションを設定しなければならない（MUST）。書き方は `vim.o` を基本とし、テーブル値が必要な `listchars` のみ `vim.opt` を用いる。

設定対象:
- 表示: `number`, `relativenumber`, `cursorline`, `signcolumn="yes"`, `scrolloff=10`, `termguicolors`, `list` + `listchars`（tab/trail/nbsp）, `wrap=false`
- インデント: `expandtab`, `shiftwidth=2`, `tabstop=2`, `smartindent`, `shiftround`, `breakindent`
- 検索: `ignorecase`, `smartcase`, `inccommand="split"`
- 編集・ファイル: `undofile`, `undolevels=10000`, `confirm`, `mouse="a"`, `clipboard="unnamedplus"`, `autoread`, `updatetime=250`, `timeoutlen=300`
- 分割: `splitright`, `splitbelow`

#### Scenario: 表示系オプションが反映される

- **WHEN** Neovim を起動する
- **THEN** 絶対行番号と相対行番号（`number`, `relativenumber`）が表示される
- **AND** カーソル行ハイライト（`cursorline`）と常時表示の sign column（`signcolumn="yes"`）が有効になる
- **AND** truecolor（`termguicolors`）が有効になる

#### Scenario: インデント・編集系オプションが反映される

- **WHEN** ファイルを編集する
- **THEN** タブはスペース 2 個に展開される（`expandtab`, `shiftwidth=2`, `tabstop=2`）
- **AND** `undofile` により再起動後も undo 履歴が保持される

#### Scenario: 検索オプションが反映される

- **WHEN** 大文字を含まない語で検索する
- **THEN** 大文字小文字を無視して一致する（`ignorecase` + `smartcase`）
- **AND** `:substitute` の置換プレビューが split で表示される（`inccommand="split"`）

### Requirement: スコープ外項目の非導入

今回の change では基本オプションのみを扱い、以下を導入してはならない（MUST NOT）。これらは将来の別 change で扱う。

#### Scenario: 今回入れない項目

- **WHEN** 本 change の成果物を確認する
- **THEN** `autoread` を実効化する `checktime` autocmd は含まれない
- **AND** `showmode=false` や `statuscolumn` などステータスラインプラグイン依存の設定は含まれない（`showmode` は既定のまま）
- **AND** keymap 定義およびプラグイン管理（lazy.nvim 等）は含まれない
