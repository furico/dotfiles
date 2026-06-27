## ADDED Requirements

### Requirement: plugins モジュールの読み込み

`init.lua` は `lua/config/plugins.lua` を `require` 経由で読み込まなければならない（MUST）。読み込みは `require("config.options")` / `require("config.keymaps")` / `require("config.autocmds")` の後に行う。プラグインの実体定義は `init.lua` に直接書かず `plugins.lua` に置く。`init.lua` に残っていた `require("config.lazy")` の予約コメントは除去しなければならない（MUST）。

#### Scenario: plugins モジュールが読み込まれる

- **WHEN** Neovim が起動し `init.lua` が評価される
- **THEN** options / keymaps / autocmds に続いて `require("config.plugins")` が評価される
- **AND** `plugins.lua` で登録されたプラグインがランタイムに載る

#### Scenario: lazy 予約コメントが残らない

- **WHEN** `init.lua` を確認する
- **THEN** `config.lazy` への参照（予約コメントを含む）が存在しない

### Requirement: vim.pack による宣言的なプラグイン登録

プラグインは Neovim 0.12 組み込みの `vim.pack` を用いて登録しなければならない（MUST）。外部プラグインマネージャ（lazy.nvim / packer / mini.deps 等）を導入してはならない（MUST NOT）。`plugins.lua` は `vim.pack.add({...})` でプラグインを宣言的に列挙する。GitHub のソース記述には完全な `https://` URL を生成する薄いローカルヘルパを用いてよく、その場合でもロックファイルに残るソースは完全な URL でなければならない（MUST。`git insteadOf` 等の短縮形をロックファイルに残してはならない）。

#### Scenario: vim.pack で登録される

- **WHEN** `plugins.lua` を確認する
- **THEN** `vim.pack.add` を用いてプラグインが登録されている
- **AND** lazy.nvim 等の外部マネージャの bootstrap コードや require は存在しない

#### Scenario: 初回起動でインストールされる

- **WHEN** プラグインが未インストールの状態で Neovim を起動する（ネットワーク到達可能）
- **THEN** `vim.pack` が data standard-path 配下（`site/pack/core/opt/`）へ clone する
- **AND** プラグインがランタイムから利用可能になる

### Requirement: 検証用 colorscheme の起動時適用

起動時に検証用の colorscheme を 1 つ適用しなければならない（MUST）。適用は失敗しても起動を中断してはならない（MUST）。プラグイン未インストール（初回オフライン等）で colorscheme が見つからない場合に備え、適用は `pcall` 等で保護し、失敗時はデフォルトのまま続行する。

#### Scenario: colorscheme が適用される

- **WHEN** colorscheme プラグインがインストール済みの状態で Neovim を起動する
- **THEN** 検証用 colorscheme が適用され、`termguicolors` 環境で配色が反映される

#### Scenario: 未インストールでも起動が壊れない

- **WHEN** colorscheme プラグインが disk に無い状態（初回ネットワーク不通等）で起動する
- **THEN** colorscheme 適用は失敗するが Neovim の起動は継続する
- **AND** エラーで停止せず、デフォルト配色のまま使える

### Requirement: ロックファイルの Git 管理

`vim.pack` のロックファイル `nvim-pack-lock.json` は Git で追跡しなければならない（MUST）。ロックファイルは `$XDG_CONFIG_HOME/nvim/`（= リポジトリへ folded された `~/.config/nvim/`）に生成されるため、実体はリポジトリ内 `neovim/.config/nvim/nvim-pack-lock.json` に置かれる。これにより別マシンで同一 revision を再現できる。ロックファイルは手編集してはならない（MUST NOT）。更新は `vim.pack.update()` の確認バッファ経由でのみ行う。

#### Scenario: ロックファイルがリポジトリで追跡される

- **WHEN** プラグイン登録後に Neovim を起動しロックファイルが生成される
- **THEN** `neovim/.config/nvim/nvim-pack-lock.json` が存在し、Git の追跡対象になっている

#### Scenario: 別マシンで revision が再現される

- **WHEN** ロックファイルを含むリポジトリを別マシンへ展開し Neovim を初回起動する
- **THEN** ロックファイルに記録された revision でプラグインが一括インストールされる

### Requirement: プラグイン管理キーマップ

プラグインの更新と現状確認を行う keymap を `<leader>p` 名前空間に定義しなければならない（MUST）。これらは `vim.pack` に依存するため `plugins.lua` に置き（`keymaps.lua` を plugin-free に保つ）、`local map = vim.keymap.set` 別名で定義し各マッピングに `desc` を付与する。最低限、全更新と（オフラインでの）現状確認の 2 つを提供する。

#### Scenario: 更新キーマップ

- **WHEN** normal モードで `<leader>pu` を押す
- **THEN** `vim.pack.update()` が実行され、別タブに更新確認バッファが開く（`:write` で確定 / `:quit` で破棄）

#### Scenario: 現状確認キーマップ

- **WHEN** normal モードで `<leader>ps` を押す
- **THEN** オフライン（ネットワークアクセスなし）で管理中プラグインの現状を確認するバッファが開く

#### Scenario: 記述スタイル

- **WHEN** `plugins.lua` のキーマップ定義を確認する
- **THEN** `local map = vim.keymap.set` 別名が使われ、各 `map(...)` に `desc` を含む opts が渡されている

### Requirement: スコープ外項目の非導入

本 change はプラグイン管理の土台と検証用 colorscheme のみを扱い、以下を導入してはならない（MUST NOT）。これらは土台が立った後の別 change で扱う。

#### Scenario: 今回入れない項目

- **WHEN** 本 change の成果物を確認する
- **THEN** LSP・補完・Treesitter・ファイラ・statusline 等の機能プラグインは含まれない
- **AND** `PackChanged` による build フックの本格運用は含まれない（検証用 colorscheme は build 不要）
- **AND** which-key 等のキーマップ基盤や `<leader>` 名前空間の体系化は含まれない
- **AND** プラグイン実体はリポジトリに含めない（ロックファイルのみ管理し、実体は data standard-path 配下に置く）
