# neovim-ui Specification

## Purpose

見た目と操作性（UI/QoL）の層を定義する。colorscheme（`catppuccin/nvim`、flavour=mocha）、statusline（`lualine.nvim`、`theme="auto"` で配色追従、`showmode=false`）、インデント縦ガイド（`indent-blankline.nvim` v3 = `ibl`）、キーマップポップアップ（`which-key.nvim`、`<leader>` グループ登録）を含む。設定は専用モジュール `lua/config/ui.lua` に分離し、`plugins.lua` の `vim.pack.add` レジストリに登録する。配色は当初 `neovim-plugins` の検証用 colorscheme 要件で扱っていたが、本 capability へ移管した。いずれも純 Lua で build 不要、未導入でも起動を壊さない。
## Requirements
### Requirement: UI プラグインの導入

UI レイヤとして `catppuccin/nvim` / `lualine.nvim` / `indent-blankline.nvim` / `which-key.nvim` を `vim.pack` で導入しなければならない（MUST）。登録は `neovim-plugins` の宣言レジストリ（`plugins.lua` の `vim.pack.add`）に追加する。いずれも純 Lua で build フックは不要であり、`version` は省略して default ブランチを用いてよい。検証用に入っていた tokyonight は registry から外す（MUST）。

#### Scenario: UI プラグインが入る

- **WHEN** `plugins.lua` の `vim.pack.add` を確認する
- **THEN** `catppuccin`（name 明示）/ `lualine.nvim` / `indent-blankline.nvim` / `which-key.nvim` が登録されている
- **AND** tokyonight は登録されていない

### Requirement: colorscheme（catppuccin）の適用

起動時に `catppuccin/nvim`（flavour=mocha）を colorscheme として適用しなければならない（MUST）。`require("catppuccin").setup({ flavour = "mocha" })` の後に `catppuccin` を colorscheme として適用する。適用は `ui.lua` で行い、lualine（`theme="auto"`）が検出できるよう lualine setup より前に行う（MUST）。適用は `pcall` 等で保護し、未導入（初回オフライン等）でも起動を中断してはならない（MUST。失敗時はデフォルト配色で継続）。`vim.pack.add` の `name` は `catppuccin` を明示する（repo 名 `nvim` を dir 名に使わない）。

#### Scenario: catppuccin が適用される

- **WHEN** catppuccin が導入済みの状態で Neovim を起動する
- **THEN** colorscheme として `catppuccin`（mocha）が適用され、`termguicolors` 環境で配色が反映される

#### Scenario: lualine より前に適用される

- **WHEN** `ui.lua` を確認する
- **THEN** catppuccin の setup と適用が lualine の setup より前にある（lualine の `theme="auto"` が追従できる）

#### Scenario: 未導入でも起動が壊れない

- **WHEN** catppuccin が disk に無い状態（初回ネットワーク不通等）で起動する
- **THEN** colorscheme 適用は失敗するが Neovim の起動・編集は継続する（デフォルト配色のまま）

### Requirement: UI 設定モジュールの分離と読み込み

UI の設定は専用モジュール `lua/config/ui.lua` に置き、`lua/config/plugins.lua` から `require` 経由で読み込まなければならない（MUST）。`plugins.lua` は `vim.pack.add` レジストリと最小初期化に保ち、UI の設定実体を直接展開してはならない（MUST NOT）。require は `pcall` 等で保護し、未導入でも起動を中断してはならない（MUST）。

#### Scenario: 専用モジュールが読み込まれる

- **WHEN** Neovim が起動し `config.plugins` が評価される
- **THEN** `require("config.ui")` が評価され、UI の設定が適用される

#### Scenario: 未導入でも起動する

- **WHEN** UI プラグインが未導入の状態（初回オフライン等）で起動する
- **THEN** UI は適用されないが Neovim の起動・編集は継続する

### Requirement: statusline と showmode

`lualine.nvim` を `theme = "auto"`（現在の colorscheme に追従）で setup しなければならない（MUST）。モード表示は lualine が担うため、`showmode` を `false` にしなければならない（MUST）。この `showmode=false` は `ui.lua` に置き、`options.lua` の予約コメントは更新するに留める（`neovim-options` の要件は変更しない）。

#### Scenario: statusline が表示される

- **WHEN** Neovim を起動する
- **THEN** lualine の statusline が表示され、テーマは現在の colorscheme に追従する

#### Scenario: 組み込みモード表示が消える

- **WHEN** 挿入モード等へ入る
- **THEN** 組み込みの `-- INSERT --` 表示は出ず（`showmode=false`）、モードは lualine に表示される

### Requirement: インデントガイド

`indent-blankline.nvim`（v3、モジュール名 `ibl`）を `require("ibl").setup({...})` で初期化し、インデントの縦ガイドを表示しなければならない（MUST）。

#### Scenario: 縦ガイドが出る

- **WHEN** インデントのあるファイルを開く
- **THEN** インデントレベルに対応する縦ガイドが表示される

### Requirement: which-key とグループ登録

`which-key.nvim` を setup し、キー押下途中に割当てをポップアップ表示しなければならない（MUST）。`<leader>` 名前空間のグループ名（少なくとも `<leader>p`=plugins、`<leader>h`=hunks、`<leader>f`=find）に加え、`s`=surround のグループ名を登録する（MUST）。group 名は `ui.lua` の `wk.add` に集約し、各 capability の実キーマップ（hunks は git.lua、find は finder.lua、surround は mini.surround の `s*` 既定）とは分離する。既存マッピングの `desc` をそのまま説明として用い、`keymaps.lua` は plugin-free に保つ。

#### Scenario: ポップアップが出る

- **WHEN** `<leader>` を押して少し待つ
- **THEN** which-key のポップアップに、その配下のマッピングが `desc` 付きで一覧表示される

#### Scenario: グループ名が付く

- **WHEN** which-key のポップアップで `<leader>p` / `<leader>h` / `<leader>f` / `s` を確認する
- **THEN** それぞれ plugins / hunks / find / surround のグループ名が表示される

### Requirement: スコープ外項目の非導入

本 capability は colorscheme・statusline・インデントガイド・which-key のみを扱い、以下を導入してはならない（MUST NOT）。別 change で扱う。

#### Scenario: 今回入れない項目

- **WHEN** 本 capability の成果物を確認する
- **THEN** ファイラ（oil/neo-tree）・bufferline/tabline・dashboard・通知（nvim-notify 等）は含まれない
- **AND** snacks 等の大型 QoL バンドルは含まれない

