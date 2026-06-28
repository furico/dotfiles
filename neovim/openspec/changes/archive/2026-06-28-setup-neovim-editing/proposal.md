## Why

LSP・補完・finder・ファイラまで揃ったが、日常の打鍵で最も体感差の出る「編集 QoL」が空いている。括弧/クォートの自動補完（auto-pairs）と囲み操作（surround）が無く、`(` を打てば手で `)` を足し、単語を `"` で囲むのも手作業になっている。`echasnovski/mini.pairs` と `echasnovski/mini.surround` は純 Lua・依存なし・build 不要で、repo の価値観（最小・自己完結・1プラグイン1役・pcall 保護・vim.pack ネイティブ）にそのまま乗る。補完エンジン blink.cmp の `default` preset は `<CR>` を使わない（確定は `<C-y>`）ため、mini.pairs の `<CR>`（ペア間で改行）と衝突しないことも確認済み。

## What Changes

- **mini.pairs（auto-pairs）導入**: `echasnovski/mini.pairs` を `vim.pack.add` レジストリに追加し、`require("mini.pairs").setup({})` を既定で有効化する。括弧/クォート `( [ { " ' \`` の自動補完、`<BS>` でペア両側削除、`<CR>` でペア間に改行＋インデントが効く。treesitter 非依存の素朴な実装で軽量（文字列/コメント内の賢い抑制は持たないが dotfiles 編集では十分）。
- **mini.surround（囲み操作）導入**: `echasnovski/mini.surround` を `vim.pack.add` レジストリに追加し、`require("mini.surround").setup({})` を既定で有効化する。`s` プレフィックスの既定マッピング（`sa` 追加 / `sd` 削除 / `sr` 置換 / `sf`・`sF` 検索 / `sh` ハイライト）を採用する。組み込みの `s`（=`cl`、1文字置換）は `timeoutlen` 後にフォールバックする（完全には失わない）。
- **editing モジュールの新設**: 既存パターン（レジストリ追加 + 専用 config モジュール）を踏襲し、「編集 QoL」の対として `lua/config/editing.lua` に両 setup を載せる。各 setup は独立に `pcall` 保護し、片方が未導入でも他方と起動を壊さない。
- **which-key グループ登録**: 慣習（`<leader>f`=find / `<leader>h`=hunks の前例）に従い、`s`=surround のグループ名登録を `ui.lua` の `wk.add` に追加する（group 名はここに集約、実マッピングは mini.surround 既定）。
- **`plugins.lua` 結線**: `vim.pack.add` に2リポジトリを足し、個別設定群に `require("config.editing")` を追記する。
- スコープに**含めない**もの: フォーマッタ（別途・今回除外）、Linter、mini の他モジュール（mini.ai/move/comment 等）、treesitter 連動の賢い auto-pairs（nvim-autopairs）。

## Capabilities

### New Capabilities
- `neovim-editing`: mini.pairs（auto-pairs）と mini.surround（囲み操作）による編集 QoL。standalone 2リポジトリの導入、専用モジュール `lua/config/editing.lua` への集約、mini.pairs の既定挙動（auto-pair / `<BS>` / `<CR>`、blink 非競合）、mini.surround の `s*` 既定マッピング、各 setup の独立 `pcall` 保護による未導入耐性を含む。

### Modified Capabilities
- `neovim-ui`: which-key のグループ登録要件に `s`=surround を追加する。既存の `<leader>p`=plugins / `<leader>h`=hunks / `<leader>f`=find に surround を加えるのみで、colorscheme・lualine・ibl 等 UI の他要件は変更しない。group 名を `ui.lua` に集約する既存方針を surround にも適用するための最小の追記。

## Impact

- 新規ファイル: `neovim/.config/nvim/lua/config/editing.lua`。
- 変更ファイル: `neovim/.config/nvim/lua/config/plugins.lua`（`vim.pack.add` への mini.pairs/mini.surround 追加と末尾 `require("config.editing")`）、`neovim/.config/nvim/lua/config/ui.lua`（which-key の `s`=surround グループ追記）、`neovim/.config/nvim/nvim-pack-lock.json`（mini.pairs/mini.surround の revision 追記）、`neovim/README.md`（編集 QoL の節を追加）。
- `~/.config/nvim` はディレクトリ単位のシンボリックリンクのため新規ファイルは `stow -R` なしで反映される。プラグイン本体は `~/.local/share/nvim/site/pack/core/opt/` に置き repo には含めない（ロックファイルのみ管理）。build ステップ・外部バイナリ依存なし（すべて純 Lua）。
- 既存パッケージ（vim, zsh, tmux）および options / keymaps / autocmds / plugins / treesitter / lsp / completion / git / finder / explorer の要件への影響なし。`neovim-ui` は which-key グループの追記のみ（既存の UI 動作は不変）。補完（blink.cmp）とのキー競合なし（`default` preset は `<CR>` 不使用）。
