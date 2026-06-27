# neovim-completion Specification

## Purpose

`Saghen/blink.cmp` による補完を提供する。補完ソースは LSP / path / snippets / buffer。release tag（v1 系）にピンして prebuilt の fuzzy バイナリを取得し（Rust ツールチェーン不要）、取得失敗時は Lua 実装にフォールバックする。設定は専用モジュール `lua/config/completion.lua` に分離し、`plugins.lua` の `vim.pack.add` レジストリに登録する。`neovim-lsp` には `get_lsp_capabilities()` を介して補完 capability を提供する。

## Requirements

### Requirement: blink.cmp の導入

補完エンジンとして `Saghen/blink.cmp` を `vim.pack` で導入しなければならない（MUST）。登録は `neovim-plugins` の宣言レジストリ（`plugins.lua` の `vim.pack.add`）に追加する。prebuilt の fuzzy バイナリを取得するため、`version` で release tag（v1 系）に semver range でピンしなければならない（MUST）。これにより Rust ツールチェーンを要求しない。

#### Scenario: blink がタグにピンされて入る

- **WHEN** `plugins.lua` の `vim.pack.add` を確認する
- **THEN** `blink.cmp` が登録され、`version` で v1 系のタグにピンされている

### Requirement: 補完設定モジュールの分離と読み込み

補完の設定は専用モジュール `lua/config/completion.lua` に置き、`lua/config/plugins.lua` から `require` 経由で読み込まなければならない（MUST）。読み込みは LSP モジュール（`config.lsp`）より前に行い、補完 capability を LSP 側が取得できるようにする。

#### Scenario: 専用モジュールが読み込まれる

- **WHEN** Neovim が起動し `config.plugins` が評価される
- **THEN** `require("config.completion")` が `require("config.lsp")` より前に評価される

### Requirement: 補完ソースとキーマップ

`blink.cmp` の `setup` で、補完ソースに少なくとも LSP / path / snippets / buffer を設定し、キーマップは `preset`（既定）を用いなければならない（MUST）。

#### Scenario: 補完が出る

- **WHEN** LSP がアタッチしたバッファで挿入モードでテキストを入力する
- **THEN** LSP / path / snippets / buffer のソースから補完候補が表示される

#### Scenario: ソース設定

- **WHEN** `completion.lua` を確認する
- **THEN** `sources.default` に `lsp` / `path` / `snippets` / `buffer` が含まれている

### Requirement: LSP への capabilities 提供

`blink.cmp` の補完 capability を LSP 側へ提供しなければならない（MUST）。`require("blink.cmp").get_lsp_capabilities()` を介して取得できるようにし、`neovim-lsp` が `vim.lsp.config("*")` へ配線する。

#### Scenario: capabilities が取得できる

- **WHEN** `require("blink.cmp").get_lsp_capabilities()` を呼ぶ
- **THEN** 組み込み LSP capabilities に blink の補完 capability をマージしたものが返る

### Requirement: prebuilt fuzzy とフォールバック

fuzzy matcher は prebuilt バイナリを優先しつつ、取得・ロードに失敗しても補完を止めてはならない（MUST）。`fuzzy.implementation = "prefer_rust_with_warning"` を用い、バイナリ不在時は警告を出して Lua 実装にフォールバックする。

#### Scenario: バイナリ未取得でも補完は動く

- **WHEN** prebuilt fuzzy バイナリが取得できていない状態で補完を使う
- **THEN** 警告は出るが Lua 実装で補完が機能し、起動・編集は継続する

### Requirement: スコープ外項目の非導入

本 capability は blink.cmp による補完のみを扱い、以下を導入してはならない（MUST NOT）。別 change で扱う。

#### Scenario: 今回入れない項目

- **WHEN** 本 capability の成果物を確認する
- **THEN** `friendly-snippets` 等の追加スニペット集は含まれない
- **AND** `nvim-cmp` や組み込み `vim.lsp.completion.enable` との併用は行わない（補完は blink に一本化）
