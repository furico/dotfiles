# neovim-explorer Specification

## Purpose
TBD - created by archiving change setup-neovim-explorer. Update Purpose after archive.
## Requirements
### Requirement: explorer モジュールの有効化

ファイラとして導入済み `folke/snacks.nvim` の `explorer` モジュールを有効化しなければならない（MUST）。有効化は中央の `require("snacks").setup(...)`（`neovim-finder` が `lua/config/snacks.lua` に集約する setup）に `explorer = { enabled = true }` を加える形で行う（MUST）。`vim.pack.add` レジストリへの新規プラグイン追加や C ビルド・外部バイナリ依存を導入してはならない（MUST NOT。snacks は既に導入済み・純 Lua）。snacks の既定 `replace_netrw = true`・`trash = true` を採用する（MUST）。explorer picker source 側の既定（tree 表示・git_status・diagnostics・follow_file・sidebar レイアウト）は変更しない（SHOULD NOT。本 change ではカスタムしない）。

#### Scenario: explorer が有効になる

- **WHEN** 中央 setup（`snacks.lua`）の引数を確認する
- **THEN** `explorer = { enabled = true }` が含まれている
- **AND** `vim.pack.add` には新規プラグインが追加されていない（snacks のみで完結）

#### Scenario: netrw を置換する

- **WHEN** `nvim <ディレクトリ>` でディレクトリを開く
- **THEN** netrw ではなく snacks.explorer が開く（`replace_netrw` 既定 true）

#### Scenario: 削除がゴミ箱へ送られる

- **WHEN** explorer ツリー内でファイルを削除する
- **THEN** `trash` 既定 true により、利用可能な trash コマンド経由でシステムのゴミ箱へ送られる
- **AND** trash コマンドが無い環境では完全削除へフォールバックして動作は継続する

### Requirement: explorer 設定モジュールの分離と読み込み

explorer の設定（キーマップ）は専用モジュール `lua/config/explorer.lua` に置き、`lua/config/plugins.lua` から `require` 経由で読み込まなければならない（MUST）。`snacks.setup` の所在（`snacks.lua`）とは分離し、`explorer.lua` 自身は setup を呼ばない（MUST NOT。capability ごとに1モジュールの方針）。require は `pcall` 等で保護し、未導入（初回オフライン等）でも起動を中断してはならない（MUST。失敗時はファイラ無しで継続）。読み込み順は setup（`snacks.lua`）の後でなければならない（MUST）。

#### Scenario: 専用モジュールが読み込まれる

- **WHEN** Neovim が起動し `config.plugins` が評価される
- **THEN** `require("config.snacks")` の後に `require("config.explorer")` が評価され、explorer のキーマップが適用される

#### Scenario: 未導入でも起動する

- **WHEN** snacks が未導入の状態（初回オフライン等）で起動する
- **THEN** ファイラは使えないが Neovim の起動・編集は継続する

### Requirement: explorer キーマップ

explorer の操作は次のキーマップを `desc` 付きで提供しなければならない（MUST）:

- `<leader>e` … ファイラを開閉する（`require("snacks").explorer()`）
- `<leader>E` … 現在のファイルをツリー内で表示する（`require("snacks").explorer.reveal()`）

これらは `<leader>f`（=find）名前空間と衝突しない単独キーであり、which-key のグループ登録（`ui.lua` の `wk.add`）を必要としない（`desc` がそのまま表示される）。ツリー内のファイル操作キー（作成 `a` / 削除 `d` / 改名 `r` / コピー `c` / 移動 `m`、折りたたみ `h` / 展開 `l` 等）は snacks.explorer の既定に委ね、本 change で再定義しない（SHOULD NOT）。キーマップは押下時に snacks を遅延参照し、未導入時もエラーにしてはならない（MUST）。

#### Scenario: ファイラを開く

- **WHEN** `<leader>e` を押す
- **THEN** snacks.explorer のサイドバーが開閉する

#### Scenario: 現在ファイルを表示する

- **WHEN** いずれかのファイルを編集中に `<leader>E` を押す
- **THEN** explorer が開き、現在のファイルがツリー内で展開・選択された状態になる

#### Scenario: 未導入でも押下が無害

- **WHEN** snacks が未導入の状態で `<leader>e` を押す
- **THEN** エラーにならず、起動・編集は継続する

### Requirement: スコープ外項目の非導入

本 capability は snacks の explorer モジュールのみを扱い、以下を導入してはならない（MUST NOT）。別 change で扱う。

#### Scenario: 今回入れない項目

- **WHEN** 本 capability の成果物を確認する
- **THEN** snacks の picker / explorer 以外のモジュール（dashboard / notifier / scroll / indent / statuscolumn 等）は有効化されていない
- **AND** oil / neo-tree / mini.files 等の別ファイラは含まれない
- **AND** explorer のキー・formatter・レイアウトのカスタム作り込みは含まれない（既定を採用）
</content>
</invoke>
