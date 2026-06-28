## MODIFIED Requirements

### Requirement: picker モジュールのみの有効化

`snacks.nvim` は picker と explorer モジュールだけを有効化しなければならない（MUST）。有効化は中央の `require("snacks").setup(...)` で行い、その setup は専用モジュール `lua/config/snacks.lua` に集約する（MUST。explorer は「picker の変装」で同じ setup を共有するため、setup を1か所に集める）。`picker` と `explorer` を有効にし、dashboard・notifier・scroll・indent・statuscolumn・animate 等の他モジュールは有効化してはならない（MUST NOT。既定の無効のまま保つ）。setup は `pcall` 等で保護し、未導入（初回オフライン等）でも起動を中断してはならない（MUST。失敗時は picker / explorer 無しで継続）。

#### Scenario: picker と explorer のみが有効になる

- **WHEN** `snacks.lua` の snacks setup を確認する
- **THEN** picker と explorer が有効化されている
- **AND** dashboard / notifier / scroll / indent 等の大型モジュールは有効化されていない

#### Scenario: 未導入でも起動が壊れない

- **WHEN** snacks が disk に無い状態（初回ネットワーク不通等）で起動する
- **THEN** picker / explorer は使えないが Neovim の起動・編集は継続する

### Requirement: finder 設定モジュールの分離と読み込み

snacks の setup（`require("snacks").setup`）は専用モジュール `lua/config/snacks.lua` に集約し、finder のキーマップ設定は専用モジュール `lua/config/finder.lua` に置かなければならない（MUST）。両モジュールは `lua/config/plugins.lua` から `require` 経由で読み込み、読み込み順は setup（`snacks.lua`）→ finder キーマップ（`finder.lua`）でなければならない（MUST）。`finder.lua` は自前で `snacks.setup` を呼んではならない（MUST NOT。setup は `snacks.lua` が担う）。`plugins.lua` は `vim.pack.add` レジストリと最小初期化に保ち、finder の設定実体を直接展開してはならない（MUST NOT）。require は `pcall` 等で保護し、未導入でも起動を中断してはならない（MUST）。

#### Scenario: setup とキーマップが分離して読み込まれる

- **WHEN** Neovim が起動し `config.plugins` が評価される
- **THEN** `require("config.snacks")` で snacks の setup が適用される
- **AND** その後に `require("config.finder")` が評価され、finder の `<leader>f` キーマップが適用される

#### Scenario: 未導入でも起動する

- **WHEN** finder プラグイン（snacks）が未導入の状態（初回オフライン等）で起動する
- **THEN** finder は使えないが Neovim の起動・編集は継続する
