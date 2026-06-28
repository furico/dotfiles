## Why

`setup-neovim-finder`（archive 済み）で snacks.picker による「探す」導線は入ったが、ディレクトリ構造を俯瞰して開く・作成/改名/削除するといった「ファイラ」の導線が組み込み netrw のみで弱い。snacks は既に導入済みで、その `explorer` モジュールは picker の上に構築されており、有効化 + キーマップだけで repo の価値観（純 Lua・build 不要・自己完結・pcall 保護）を一切崩さずにファイラを足せる。新規プラグイン導入ゼロで最も体感差の大きい穴を埋める。

## What Changes

- **snacks.setup の中央集約**: 現在 `finder.lua` にある `require("snacks").setup(...)` を新規 `lua/config/snacks.lua` に切り出す。explorer は「picker の変装」で同じ setup を共有するため、setup を1か所に集約し、`finder.lua` と新規 `explorer.lua` は各自の capability のキーマップだけを足す構成にする（capability ごとに1モジュールの既存方針を維持）。
- **explorer モジュールの有効化**: `snacks.lua` の setup に `explorer = { enabled = true }` を加える。既定の `replace_netrw = true`（`nvim <dir>` で netrw の代わりに explorer）・`trash = true`（削除はシステムのゴミ箱へ。`trash` コマンドは環境に導入済み）はそのまま採用する。picker source 側の既定（tree / git_status / diagnostics / follow_file / sidebar レイアウト）も変更しない。
- **explorer モジュールの新設**: `lua/config/explorer.lua` を新設し、`<leader>e`=ファイラ開閉（`Snacks.explorer()`）、`<leader>E`=現在ファイルをツリー表示（`Snacks.explorer.reveal()`）を `desc` 付きで定義する。`require` は `pcall` 保護で未導入・オフラインでも起動を壊さない。
- **`finder.lua` のリファクタ**: 自前の `snacks.setup` 呼び出しを除去し、キーマップ定義のみを残す（setup は `snacks.lua` が担う）。`<leader>f` 名前空間のキーマップ群は不変。
- **`plugins.lua` 結線**: 個別設定の require 順を `snacks`（setup）→ `finder`（keymap）→ `explorer`（keymap）に整える。`vim.pack.add` レジストリは変更しない（snacks は既に登録済み）。
- スコープに**含めない**もの: snacks の picker / explorer 以外のモジュール（dashboard/notifier/scroll/indent 等）、explorer のキーや formatter のカスタム作り込み（既定を採用）、oil/neo-tree 等の別ファイラ。

## Capabilities

### New Capabilities
- `neovim-explorer`: snacks.explorer によるファイラ。専用モジュール `lua/config/explorer.lua` への分離、`<leader>e`=開閉 / `<leader>E`=現在ファイル表示のキーマップ、`replace_netrw` / `trash` 既定の採用、`pcall` 保護による未導入耐性を含む。

### Modified Capabilities
- `neovim-finder`: snacks の setup 集約とモジュール許可範囲を変更する。(1) `require("snacks").setup` の所在を `finder.lua` から新規 `lua/config/snacks.lua` に移し、`finder.lua` はキーマップのみを持つ。(2)「picker モジュールのみの有効化」要件を「picker と explorer の有効化（他の大型モジュールは非有効）」へ緩める。`<leader>f` キーマップ群と未導入耐性の要件は不変。

## Impact

- 新規ファイル: `neovim/.config/nvim/lua/config/snacks.lua`（中央 setup）、`neovim/.config/nvim/lua/config/explorer.lua`（explorer キーマップ）。
- 変更ファイル: `neovim/.config/nvim/lua/config/finder.lua`（自前 setup の除去、キーマップは維持）、`neovim/.config/nvim/lua/config/plugins.lua`（require 順を snacks → finder → explorer に整理）、`neovim/README.md`（explorer の節を追加）。
- `vim.pack.add` レジストリ・`nvim-pack-lock.json` は変更なし（snacks は既に導入済み）。
- `~/.config/nvim` はディレクトリ単位のシンボリックリンクのため新規ファイルは `stow -R` なしで反映される。build ステップ・外部バイナリ依存なし（すべて純 Lua。削除のゴミ箱送りは導入済みの `trash` コマンドを利用、未導入時も完全削除へフォールバックして動作）。
- `neovim-ui` への影響なし: `<leader>e`/`<leader>E` は単独キーで which-key グループ登録を要さず、`ui.lua` の `wk.add` は変更しない。options / keymaps / autocmds / plugins / treesitter / lsp / completion / git の各要件への影響もなし。
