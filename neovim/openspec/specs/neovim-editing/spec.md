# neovim-editing Specification

## Purpose
TBD - created by archiving change setup-neovim-editing. Update Purpose after archive.
## Requirements
### Requirement: 編集 QoL プラグインの導入

auto-pairs として `echasnovski/mini.pairs` を、囲み操作として `echasnovski/mini.surround` を、それぞれ standalone リポジトリとして `vim.pack` で導入しなければならない（MUST）。登録は `neovim-plugins` の宣言レジストリ（`plugins.lua` の `vim.pack.add`）に2エントリ追加する。いずれも純 Lua で build フックは不要であり、`version` は省略して default ブランチを用いてよい（MUST）。フル `mini.nvim` モノレポや C ビルド・外部バイナリに依存してはならない（MUST NOT。1プラグイン1役の方針）。

#### Scenario: 2リポジトリが入る

- **WHEN** `plugins.lua` の `vim.pack.add` を確認する
- **THEN** `echasnovski/mini.pairs` と `echasnovski/mini.surround` が登録されている
- **AND** フル `mini.nvim` は登録されていない
- **AND** いずれも `version` 指定はなく default ブランチが使われる

### Requirement: editing 設定モジュールの分離と読み込み

編集 QoL の設定は専用モジュール `lua/config/editing.lua` に集約し、`lua/config/plugins.lua` から `require` 経由で読み込まなければならない（MUST）。`plugins.lua` は `vim.pack.add` レジストリと最小初期化に保ち、editing の設定実体を直接展開してはならない（MUST NOT）。mini.pairs と mini.surround の `setup` は独立に `pcall` 等で保護し、片方が未導入（初回オフライン等）でも他方および Neovim の起動・編集を中断してはならない（MUST）。

#### Scenario: 専用モジュールが読み込まれる

- **WHEN** Neovim が起動し `config.plugins` が評価される
- **THEN** `require("config.editing")` が評価され、mini.pairs / mini.surround の設定が適用される

#### Scenario: 片方未導入でも起動する

- **WHEN** mini.pairs または mini.surround の一方が未導入の状態（初回オフライン等）で起動する
- **THEN** その機能は使えないが、他方および Neovim の起動・編集は継続する

### Requirement: mini.pairs の自動ペア挙動

`require("mini.pairs").setup(...)` を有効化し、インサートモードで括弧/クォート（`( [ { " ' \``）を入力したとき対応する閉じ側を自動補完しなければならない（MUST）。`<BS>` でペアの両側をまとめて削除し、`<CR>` でペアの間に改行とインデントを行う既定挙動を保つ（SHOULD。本 change ではキーや規則をカスタムしない）。補完エンジン blink.cmp の `default` preset は `<CR>` を確定に使わない（確定は `<C-y>`）ため、mini.pairs の `<CR>` マッピングは補完と競合してはならない（MUST NOT）。

#### Scenario: 括弧が自動で閉じる

- **WHEN** インサートモードで `(` を入力する
- **THEN** `)` が自動補完され、カーソルはペアの内側に置かれる

#### Scenario: 補完の確定と競合しない

- **WHEN** 補完候補の表示中に `<CR>` を押す
- **THEN** blink.cmp の確定（`<C-y>`）とは独立に、mini.pairs の改行挙動が働き、補完が誤確定されない

### Requirement: mini.surround の囲み操作（`s*` 既定）

`require("mini.surround").setup(...)` を有効化し、`s` プレフィックスの既定マッピングを採用しなければならない（MUST）。少なくとも追加 `sa`・削除 `sd`・置換 `sr` を提供する（MUST）。組み込みの `s`（=`cl`、1文字置換）は `timeoutlen` 後にフォールバックする想定で、別プレフィックスへの移設は本 change では行わない（SHOULD NOT）。

#### Scenario: 単語を囲む

- **WHEN** 単語上で `saiw"` を実行する
- **THEN** 単語が `"` で囲まれる

#### Scenario: 囲みを外す・変える

- **WHEN** `"` で囲まれた箇所で `sd"` を実行する
- **THEN** 囲みの `"` が削除される
- **AND** 代わりに `sr"'` を実行すると囲みが `'` に置換される

### Requirement: スコープ外項目の非導入

本 capability は mini.pairs と mini.surround のみを扱い、以下を導入してはならない（MUST NOT）。別 change で扱う。

#### Scenario: 今回入れない項目

- **WHEN** 本 capability の成果物を確認する
- **THEN** フォーマッタ・Linter は含まれない
- **AND** mini の他モジュール（mini.ai / move / comment / files 等）は導入されていない
- **AND** treesitter 連動の賢い auto-pairs（nvim-autopairs 等）は導入されていない
