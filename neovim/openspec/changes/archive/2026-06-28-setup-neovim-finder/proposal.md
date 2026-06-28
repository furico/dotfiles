## Why

`setup-neovim-ui`（archive 済み）までで編集体験と見た目は整ったが、ファイルを開く・プロジェクト内を検索するといった「探す」導線が組み込み（`:find` / `:grep` / `:buffers`）のみで弱い。実用上もっとも体感差が大きい穴であり、fuzzy finder を1枚入れて移動・検索の起点を作る。バックエンドは repo の価値観（純 Lua・build 不要・自己完結）に最も適う `folke/snacks.nvim` の picker モジュールを採用する（外部バイナリ不要・C ビルド不要、which-key と作者が揃う）。

## What Changes

- **snacks.nvim（picker のみ）**: `folke/snacks.nvim` を `vim.pack.add` レジストリに追加し、`require("snacks").setup(...)` で **picker モジュールだけを有効化**する。dashboard・notifier・統計・アニメ等の他モジュールは有効化しない（既定の無効のまま）。純 Lua・build フック不要のため `version` は省略し default ブランチ。
- **finder モジュールの新設**: 既存パターン（レジストリ追加 + 専用 config モジュール）を踏襲し、`lua/config/finder.lua` を新設。snacks.picker の setup と `<leader>f`（=find）名前空間のキーマップ群をここに集約する。`require` は `pcall` 保護で未導入・オフラインでも起動を壊さない。
- **`<leader>f` キーマップ群**: ファイル検索 `ff`、プロジェクト grep `fg`、カーソル下の語で grep `fw`、バッファ `fb`、最近のファイル `fr`、ヘルプ `fh`、キーマップ `fk`、診断 `fd`、ドキュメントシンボル（LSP）`fs`、直前の picker 再開 `fl` を `desc` 付きで定義する。すべて `<leader>f` 配下に収め、repo の規律ある名前空間運用を踏襲する。
- **which-key グループ登録**: 慣習（`<leader>h`=hunks の前例）に従い、`<leader>f`=find のグループ名登録は `ui.lua` の `wk.add` に追加する（group 名はここに集約、実キーマップは finder.lua）。
- **`plugins.lua` 結線**: `vim.pack.add` に snacks を足し、末尾で `require("config.finder")` を読み込む（既存の require 群に追記）。
- スコープに**含めない**もの: LSP ナビ（`gd`/`grr` 等）の picker 置き換え（`neovim-lsp` の組み込みデフォルトは維持）、ファイラ（oil/neo-tree）、snacks の picker 以外のモジュール（dashboard/notifier/scroll/indent 等）、git 用 picker（`<leader>h` は gitsigns のまま）。別 change で扱う。

## Capabilities

### New Capabilities
- `neovim-finder`: snacks.picker による fuzzy finder。picker モジュールのみの有効化、専用モジュール `lua/config/finder.lua` への分離、`<leader>f` 名前空間のファイル/grep/バッファ/最近/ヘルプ/キーマップ/診断/シンボル/再開キーマップ、`pcall` 保護による未導入耐性を含む。

### Modified Capabilities
- `neovim-ui`: which-key のグループ登録要件に `<leader>f`=find を追加する。`<leader>p`=plugins / `<leader>h`=hunks に finder の `<leader>f` を加えるのみで、colorscheme・lualine・ibl 等 UI の他要件は変更しない。group 名を `ui.lua` に集約する既存方針（hunks の前例）を finder にも適用するための最小の追記。

## Impact

- 新規ファイル: `neovim/.config/nvim/lua/config/finder.lua`。
- 変更ファイル: `neovim/.config/nvim/lua/config/plugins.lua`（`vim.pack.add` への snacks 追加と末尾 `require("config.finder")`）、`neovim/.config/nvim/lua/config/ui.lua`（which-key の `<leader>f`=find グループ追記）、`neovim/.config/nvim/nvim-pack-lock.json`（snacks の revision 追記）、`neovim/README.md`（finder の節を追加）。
- `~/.config/nvim` はディレクトリ単位のシンボリックリンクのため新規ファイルは `stow -R` なしで反映される。
- プラグイン本体は `~/.local/share/nvim/site/pack/core/opt/` に置き repo には含めない（ロックファイルのみ管理）。build ステップ・外部バイナリ依存なし（すべて純 Lua）。
- 既存パッケージ（vim, zsh, tmux）および neovim-options / -keymaps / -autocmds / -plugins / -treesitter / -lsp / -completion / -git の要件への影響なし。`neovim-ui` は which-key グループの追記のみ（既存の UI 動作は不変）。
