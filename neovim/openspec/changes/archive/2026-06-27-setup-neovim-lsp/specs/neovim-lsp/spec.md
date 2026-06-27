## ADDED Requirements

### Requirement: LSP プラグインの導入

LSP のために `mason.nvim` / `nvim-lspconfig` / `mason-lspconfig.nvim`（v2）を `vim.pack` で導入しなければならない（MUST）。登録は `neovim-plugins` の宣言レジストリ（`plugins.lua` の `vim.pack.add`）に追加する。設定の中心は組み込み `vim.lsp`（`vim.lsp.config` / `vim.lsp.enable`）に置き、`nvim-lspconfig` は各サーバの設定データ（`lsp/*.lua`）供給源として用いる。旧来の `lspconfig.<server>.setup{}` ラッパは用いてはならない（MUST NOT）。

#### Scenario: LSP プラグインが入る

- **WHEN** `plugins.lua` の `vim.pack.add` を確認する
- **THEN** `mason.nvim` / `nvim-lspconfig` / `mason-lspconfig.nvim` が登録されている

#### Scenario: 組み込み vim.lsp を土台にする

- **WHEN** `lsp.lua` を確認する
- **THEN** サーバ有効化は `vim.lsp.enable`（mason-lspconfig の `automatic_enable` 経由）で行われ、`lspconfig.<server>.setup{}` 形式は使われていない

### Requirement: LSP 設定モジュールの分離と読み込み

LSP の設定は専用モジュール `lua/config/lsp.lua` に置き、`lua/config/plugins.lua` から `require` 経由で読み込まなければならない（MUST）。`plugins.lua` は `vim.pack.add` レジストリと最小初期化に保ち、LSP の設定実体を直接展開してはならない（MUST NOT）。

#### Scenario: 専用モジュールが読み込まれる

- **WHEN** Neovim が起動し `config.plugins` が評価される
- **THEN** `require("config.lsp")` が評価され、LSP の設定が適用される

### Requirement: mason によるサーバ調達と自動有効化

最小セットの言語サーバ `lua_ls` / `bashls` / `jsonls` / `yamlls` / `taplo` を mason の `ensure_installed` で調達しなければならない（MUST）。`mason.setup()` を `mason-lspconfig.setup()` より先に呼び、`mason-lspconfig` の `automatic_enable`（既定 true）でインストール済みサーバを `vim.lsp.enable()` 有効化する。サーバ一覧は単一のリストで一元管理し、追加が容易でなければならない（MUST）。サーバ実体はリポジトリに含めず、`ensure_installed` のリストから再現する（MUST）。

#### Scenario: 最小セットが調達・有効化される

- **WHEN** 初回に Neovim を起動する（ネットワーク到達可能）
- **THEN** mason が `ensure_installed` のサーバを取得し、インストール済みになったものは `vim.lsp.enable()` で有効化される

#### Scenario: セットアップ順序

- **WHEN** `lsp.lua` を確認する
- **THEN** `mason.setup()` が `mason-lspconfig.setup()` より前に呼ばれている

#### Scenario: サーバ追加が一箇所

- **WHEN** 対象サーバを増やしたい
- **THEN** `ensure_installed` のリストに 1 エントリ足すだけで対象に含まれる

### Requirement: 補完 capability の配線

補完エンジン（`neovim-completion`）が提供する LSP capability を、全サーバの既定設定へ配線しなければならない（MUST）。`vim.lsp.config("*", { capabilities = <補完エンジンの capabilities> })` を、`mason-lspconfig.setup()`（`automatic_enable` による `vim.lsp.enable`）より前に設定し、enable 時に解決される設定へ確実に含める。

#### Scenario: 全サーバに補完 capability が乗る

- **WHEN** いずれかのサーバがアタッチする
- **THEN** そのクライアントの capabilities に補完エンジン由来の補完 capability が含まれている

#### Scenario: 配線順序

- **WHEN** `lsp.lua` を確認する
- **THEN** `vim.lsp.config("*", ...)` の capabilities 設定が `mason-lspconfig.setup()` より前にある

### Requirement: 診断表示の設定

診断表示の妥当な最小デフォルトを `vim.diagnostic.config({...})` で設定しなければならない（MUST）。設定は `lsp.lua` に置き、`neovim-options` の要件を変更しない。

#### Scenario: 診断が表示される

- **WHEN** サーバが診断を報告する
- **THEN** `vim.diagnostic.config` の設定（virtual_text 等）に従って診断が表示される

### Requirement: LSP キーマップ（デフォルト活用 + LspAttach 補完）

nvim 0.11+ のデフォルト LSP キーマップ（`grn` / `gra` / `grr` / `gri` / `K` / `[d` / `]d` 等）を再定義してはならない（MUST NOT）。不足分は `LspAttach` autocmd でバッファローカルに最小限だけ補い（例: `gd` = 定義へ）、`clear=true` の専用 augroup で冪等に登録する（MUST）。各マッピングには `desc` を付け、LSP 依存のため `lsp.lua` に置く（`keymaps.lua` は plugin-free に保つ）。

#### Scenario: アタッチ時にバッファローカルキーマップが付く

- **WHEN** いずれかのサーバがバッファにアタッチする（`LspAttach`）
- **THEN** そのバッファに `gd`（定義へ）等の補助キーマップが `desc` 付きで設定される

#### Scenario: デフォルトは再定義しない

- **WHEN** `lsp.lua` を確認する
- **THEN** `grn` / `gra` / `grr` / `K` 等の 0.11+ デフォルトを上書き再定義していない

#### Scenario: 再ソースで二重登録されない

- **WHEN** 設定を再ソースする
- **THEN** `LspAttach` の augroup がクリアされてから再登録され、重複しない

### Requirement: 失敗・不在に強い起動

LSP プラグイン未インストール・サーバ未導入・ランタイム不在でも Neovim の起動を中断してはならない（MUST）。`require("mason")` / `require("mason-lspconfig")` 等は `pcall` 等で保護する。ランタイム（Node 等）不在のサーバは当該サーバのみ無効とし、他へ波及させない。

#### Scenario: 未インストールでも起動する

- **WHEN** プラグインやサーバが未導入の状態（初回オフライン等）で起動する
- **THEN** LSP は付かないが Neovim の起動・編集は継続する

### Requirement: スコープ外項目の非導入

本 capability は LSP の有効化・サーバ調達・診断・キーマップ・補完 capability 配線のみを扱い、以下を導入してはならない（MUST NOT）。別 change で扱う。

#### Scenario: 今回入れない項目

- **WHEN** 本 capability の成果物を確認する
- **THEN** フォーマッタ（conform.nvim）・linter（nvim-lint）は含まれない
- **AND** 最小セット以外の追加言語サーバは含まれない
- **AND** インレイヒント・コードレンズ等の高度機能は含まれない
