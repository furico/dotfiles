## ADDED Requirements

### Requirement: finder プラグインの導入

fuzzy finder として `folke/snacks.nvim` を `vim.pack` で導入しなければならない（MUST）。登録は `neovim-plugins` の宣言レジストリ（`plugins.lua` の `vim.pack.add`）に追加する。純 Lua で build フックは不要であり、`version` は省略して default ブランチを用いてよい（MUST）。外部バイナリ（fzf 等）や C ビルドに依存してはならない（MUST NOT）。

#### Scenario: finder プラグインが入る

- **WHEN** `plugins.lua` の `vim.pack.add` を確認する
- **THEN** `folke/snacks.nvim` が登録されている
- **AND** `version` 指定はなく default ブランチが使われる

### Requirement: picker モジュールのみの有効化

`snacks.nvim` は picker モジュールだけを有効化しなければならない（MUST）。`require("snacks").setup(...)` で picker を有効にし、dashboard・notifier・scroll・indent・statuscolumn・animate 等の他モジュールは有効化してはならない（MUST NOT。既定の無効のまま保つ）。setup は `pcall` 等で保護し、未導入（初回オフライン等）でも起動を中断してはならない（MUST。失敗時は finder 無しで継続）。

#### Scenario: picker のみが有効になる

- **WHEN** finder.lua の snacks setup を確認する
- **THEN** picker が有効化されている
- **AND** dashboard / notifier / scroll / indent 等の大型モジュールは有効化されていない

#### Scenario: 未導入でも起動が壊れない

- **WHEN** snacks が disk に無い状態（初回ネットワーク不通等）で起動する
- **THEN** picker は使えないが Neovim の起動・編集は継続する

### Requirement: finder 設定モジュールの分離と読み込み

finder の設定は専用モジュール `lua/config/finder.lua` に置き、`lua/config/plugins.lua` から `require` 経由で読み込まなければならない（MUST）。`plugins.lua` は `vim.pack.add` レジストリと最小初期化に保ち、finder の設定実体を直接展開してはならない（MUST NOT）。require は `pcall` 等で保護し、未導入でも起動を中断してはならない（MUST）。

#### Scenario: 専用モジュールが読み込まれる

- **WHEN** Neovim が起動し `config.plugins` が評価される
- **THEN** `require("config.finder")` が評価され、finder の設定が適用される

#### Scenario: 未導入でも起動する

- **WHEN** finder プラグインが未導入の状態（初回オフライン等）で起動する
- **THEN** finder は使えないが Neovim の起動・編集は継続する

### Requirement: `<leader>f` 名前空間のキーマップ

finder の操作は `<leader>f`（=find）名前空間に集約して定義しなければならない（MUST）。少なくとも以下を `desc` 付きで提供する（MUST）:

- `<leader>ff` … ファイル検索（files）
- `<leader>fg` … プロジェクト grep（live grep）
- `<leader>fw` … カーソル下の語で grep
- `<leader>fb` … バッファ一覧
- `<leader>fr` … 最近開いたファイル
- `<leader>fh` … ヘルプタグ
- `<leader>fk` … キーマップ
- `<leader>fd` … 診断（diagnostics）
- `<leader>fs` … ドキュメントシンボル（LSP）
- `<leader>fl` … 直前の picker を再開（resume）

キーマップは snacks.picker の対応 API を呼び、`desc` は which-key にそのまま活きる文言にする。`gd`/`grr` 等の LSP ナビゲーション既定（`neovim-lsp`）は置き換えてはならない（MUST NOT）。

#### Scenario: ファイル検索が開く

- **WHEN** `<leader>ff` を押す
- **THEN** snacks.picker のファイル検索 UI が開き、選択でそのファイルを開ける

#### Scenario: プロジェクト grep が開く

- **WHEN** `<leader>fg` を押す
- **THEN** snacks.picker の grep UI が開き、入力に対する一致行を絞り込める

#### Scenario: `<leader>f` 配下に集約される

- **WHEN** which-key で `<leader>f` を確認する
- **THEN** files / grep / buffers / recent / help / keymaps / diagnostics / symbols / resume 等が `desc` 付きで一覧表示される

### Requirement: スコープ外項目の非導入

本 capability は snacks の picker モジュールのみを扱い、以下を導入してはならない（MUST NOT）。別 change で扱う。

#### Scenario: 今回入れない項目

- **WHEN** 本 capability の成果物を確認する
- **THEN** snacks の picker 以外のモジュール（dashboard / notifier / scroll / indent / statuscolumn 等）は有効化されていない
- **AND** ファイラ（oil/neo-tree）・LSP ナビの picker 置き換え・git 専用 picker は含まれない
