## Why

`setup-neovim-lsp`（archive 済み）で編集体験の中核を入れた。次は見た目と操作性の底上げ（UI/QoL）。これまでの change が残した伏線を回収できる回でもある: `options.lua` は「`showmode` は statusline プラグイン導入時に false へ」、`keymaps` は「`desc` は which-key 導入時にゼロコストで効く」「`<leader>` 系はプラグイン導入回で扱う」、`autocmds` は「末尾空白トリムは gitsigns / conform.nvim の粒度が来る回へ先送り」と書いていた。いずれも純 Lua・build 不要のプラグインで、`vim.pack`・既存路線のまま薄く積める。

## What Changes

- **lualine（statusline）**: `nvim-lualine/lualine.nvim` を導入し、`theme = "auto"`（colorscheme 追従）で setup。あわせて `showmode` を `false` にする（モード表示は lualine が担うため組み込み表示は不要）。`showmode=false` は lualine と同じ関心として `ui.lua` 側に置き、`options.lua` のコメントを更新する（`neovim-options` の要件は変えない）。
- **which-key**: `folke/which-key.nvim` を導入し、キー押下途中に割当てをポップアップ表示。`<leader>` 名前空間のグループ名（例 `<leader>p`=plugins、`<leader>h`=hunks）を登録する。既存の `desc` がそのまま説明として活きる。
- **gitsigns**: `lewis6991/gitsigns.nvim` を導入し、git の変更を sign 列に表示。`on_attach` でバッファローカルに hunk ナビ（`]c`/`[c`）と `<leader>h` 系の hunk 操作（stage/reset/preview）・blame を `desc` 付きで定義する。
- **indent guides**: `lukas-reineke/indent-blankline.nvim`（v3、モジュール名 `ibl`）を導入し、インデントの縦ガイドを表示。
- **colorscheme を catppuccin へ**: 暫定の検証用 colorscheme（tokyonight、plugins.lua にインライン）を本命の `catppuccin/nvim`（flavour=mocha）へ差し替える。配色は UI レイヤの責務に格上げし、`ui.lua` で setup・適用する。tokyonight は registry から外す。catppuccin は将来の tmux テーマ回で公式 `catppuccin/tmux` と揃えられる点も選定理由（tmux 自体は本 change のスコープ外）。`vim.pack.add` の `name` は dir 名が repo 名 `nvim` になるのを避けるため `catppuccin` を明示する。
- **モジュール構成**: 既存パターン（レジストリ追加 + 専用 config モジュール）を踏襲し、`lua/config/ui.lua`（lualine + ibl + which-key + showmode=false）と `lua/config/git.lua`（gitsigns）を新設。`plugins.lua` の `vim.pack.add` に4プラグインを足し、末尾で `require("config.ui")` → `require("config.git")`。
- いずれも純 Lua で build フックは不要。`vim.pack` の `version` は省略し default ブランチ（tokyonight と同じ扱い）。require は `pcall` 保護で未導入・オフラインでも起動を壊さない。
- スコープに**含めない**もの: ファイラ（oil/neo-tree）・bufferline/tabline・dashboard・通知（nvim-notify 等）・フォーマッタ/linter・**末尾空白トリム（conform 回）**・snacks 等の大型 QoL バンドル。別 change で扱う。

## Capabilities

### New Capabilities
- `neovim-ui`: 見た目・操作性の UI レイヤ。**colorscheme（catppuccin）の適用**、lualine（statusline、`showmode=false` 化）、indent-blankline（インデント縦ガイド）、which-key（キーマップのポップアップ表示と `<leader>` グループ登録）を含む。
- `neovim-git`: gitsigns による git 統合。sign 列での変更表示、hunk ナビ（`]c`/`[c`）と `<leader>h` 系 hunk 操作・blame のバッファローカルキーマップを含む。

### Modified Capabilities
- `neovim-plugins`: 「検証用 colorscheme の起動時適用」要件を **REMOVED** する。暫定の tokyonight から本命 catppuccin へ移行し、配色を UI レイヤ（neovim-ui）の責務へ格上げするため。`vim.pack.add で宣言的に列挙` 等の他要件は変更しない（catppuccin を同じレジストリに足し、tokyonight を外すだけ）。

## Impact

- 新規ファイル: `neovim/.config/nvim/lua/config/ui.lua`、`neovim/.config/nvim/lua/config/git.lua`。
- 変更ファイル: `neovim/.config/nvim/lua/config/plugins.lua`（`vim.pack.add` への catppuccin 追加・tokyonight 削除と他4プラグイン追加、tokyonight 適用ブロックの削除、require 2行）、`neovim/.config/nvim/lua/config/options.lua`（`showmode` コメントの更新）、`neovim/.config/nvim/nvim-pack-lock.json`（revision 追記・tokyonight 削除）、`neovim/README.md`（colorscheme/UI/git の節を更新）。
- `~/.config/nvim` はディレクトリ単位のシンボリックリンクのため新規ファイルは `stow -R` なしで反映される。
- プラグイン本体は `~/.local/share/nvim/site/pack/core/opt/` に置き repo には含めない（ロックファイルのみ管理）。build ステップ・外部バイナリ依存なし（すべて純 Lua）。
- 既存パッケージ（vim, zsh, tmux）および neovim-options / -keymaps / -autocmds / -plugins / -treesitter / -lsp / -completion の要件への影響なし。
