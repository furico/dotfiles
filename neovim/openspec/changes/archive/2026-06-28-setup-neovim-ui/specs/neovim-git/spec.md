## ADDED Requirements

### Requirement: gitsigns の導入

git 統合として `lewis6991/gitsigns.nvim` を `vim.pack` で導入しなければならない（MUST）。登録は `neovim-plugins` の宣言レジストリ（`plugins.lua` の `vim.pack.add`）に追加する。純 Lua で build フックは不要であり、`version` は省略して default ブランチを用いてよい。

#### Scenario: gitsigns が入る

- **WHEN** `plugins.lua` の `vim.pack.add` を確認する
- **THEN** `gitsigns.nvim` が登録されている

### Requirement: git 設定モジュールの分離と読み込み

gitsigns の設定は専用モジュール `lua/config/git.lua` に置き、`lua/config/plugins.lua` から `require` 経由で読み込まなければならない（MUST）。require は `pcall` 等で保護し、未導入でも起動を中断してはならない（MUST）。

#### Scenario: 専用モジュールが読み込まれる

- **WHEN** Neovim が起動し `config.plugins` が評価される
- **THEN** `require("config.git")` が評価され、gitsigns の設定が適用される

### Requirement: sign 列での変更表示

git 管理下のバッファで、行の追加・変更・削除を sign 列に表示しなければならない（MUST）。

#### Scenario: 変更が sign に出る

- **WHEN** git 管理下のファイルを編集する
- **THEN** 追加・変更・削除した行に対応する sign が sign 列に表示される

### Requirement: hunk ナビと操作キーマップ

`gitsigns.setup` の `on_attach` で、git 管理下のバッファにのみバッファローカルな hunk キーマップを `desc` 付きで定義しなければならない（MUST）。最低限、次の hunk へ `]c`・前の hunk へ `[c`（diff モード時は組み込みの `]c`/`[c` にフォールバックする）と、`<leader>h` 名前空間での hunk 操作（stage / reset / preview）・blame を提供する。`<leader>h` のグループ名（hunks）は which-key（`ui.lua`）側で登録する。

#### Scenario: hunk 間を移動する

- **WHEN** 変更のあるファイルで `]c` / `[c` を押す
- **THEN** 次 / 前の hunk へカーソルが移動する

#### Scenario: hunk を操作する

- **WHEN** hunk 上で `<leader>h` 系のキー（stage / reset / preview のいずれか）を押す
- **THEN** 対応する hunk 操作（ステージ / 取り消し / プレビュー）が実行される

#### Scenario: diff モードではフォールバック

- **WHEN** diff モードで `]c` / `[c` を押す
- **THEN** gitsigns の hunk ナビではなく組み込みの `]c` / `[c`（差分間移動）が機能する

### Requirement: スコープ外項目の非導入

本 capability は gitsigns による sign 表示・hunk 操作・blame のみを扱い、以下を導入してはならない（MUST NOT）。別 change で扱う。

#### Scenario: 今回入れない項目

- **WHEN** 本 capability の成果物を確認する
- **THEN** 末尾空白の自動トリムは含まれない（conform.nvim の粒度が来る回へ先送り）
- **AND** git クライアント統合（fugitive / neogit 等）や diffview は含まれない
