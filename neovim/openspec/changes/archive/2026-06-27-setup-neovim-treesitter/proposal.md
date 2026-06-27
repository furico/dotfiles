## Why

`setup-neovim-plugins`（archive 済み）で `vim.pack` を土台としたプラグイン管理基盤を立て、検証用 colorscheme で「インストール → 起動時適用」を確認した。本 change はその上に積む**最初の機能プラグイン回**であり、`nvim-treesitter` を入れて構文ハイライト・折りたたみを実用化する。素の正規表現ハイライトより正確な構文認識が得られ、dotfiles で日常的に触る lua / shell / 各種設定ファイルの編集体験が上がる。あわせて、`setup-neovim-plugins` で「土台が立った後の別 change で扱う」と先送りした `PackChanged` build フックの初実用ケースとなる（パーサのコンパイル／更新を vim.pack のイベントで配線する）。

## What Changes

- `nvim-treesitter` を **main ブランチ**で導入する。main は組み込み `vim.treesitter` に土台を委譲した書き直し版で、プラグインの役割はパーサのインストーラと query 供給に縮小する。nvim 0.12 の思想（`vim.pack` 同様「組み込みを土台に薄く積む」）と一致する。最低 nvim 0.12.0 必須で、本環境 0.12.3 が満たす。
- `lua/config/plugins.lua` の `vim.pack.add` レジストリに `{ src = ".../nvim-treesitter", version = "main" }` を追加する。default ブランチが `master`（legacy）のため、`version = "main"` の明示ピンが必須。
- treesitter 固有の設定を新モジュール `lua/config/treesitter.lua` に分離し、`plugins.lua` から `require` する。以降のプラグインも「レジストリに追加 + 専用 config モジュール」パターンで足せる形にする。
- **ハイライト**: `FileType` autocmd で `vim.treesitter.start()` を呼ぶ（main では自前配線が必要）。
- **折りたたみ**: `vim.treesitter.foldexpr()` を `foldexpr` に設定。開いた瞬間に全折りたたみされないよう fold 関連オプション（`foldlevelstart` 等）を「開いた状態で始まる」値にする。
- **インデント（実験的）**: main の `indentexpr` を有効化する（採否・filetype 限定の有無は design で確定）。
- **build フック**: `vim.pack` の `PackChanged` autocmd で、install / update 時に対象言語の install と `:TSUpdate` を走らせ、parser と query の整合を保つ。起動時にも `require("nvim-treesitter").install(langs)` を非同期で呼び未導入分を冪等に補う。
- **初期言語セット**（後で1行追加で拡張できる最小構成）: `lua`, `vim`, `vimdoc`, `query`, `bash`, `markdown`, `markdown_inline`, `json`, `yaml`, `toml`, `diff`, `gitcommit`。この dotfiles repo で実際に編集するものを中心に選ぶ。
- スコープに**含めない**もの: LSP・補完・他の機能プラグイン、treesitter の `incremental_selection` 等の追加モジュール、textobjects。これらは別 change で扱う。

## Capabilities

### New Capabilities
- `neovim-treesitter`: `nvim-treesitter`（main ブランチ）を `vim.pack` で導入し、`vim.treesitter.start()` によるハイライト・`foldexpr` による折りたたみ・（実験的）インデントを有効化する。対象言語の宣言、`PackChanged` による build フック（install/update での parser コンパイルと `:TSUpdate`）、専用 config モジュール `config.treesitter` の読み込みを含む。

### Modified Capabilities
<!-- なし。neovim-plugins の「vim.pack.add で宣言的に列挙」要件はそのまま満たし（treesitter を同じレジストリに足すだけ）、既存要件は変更しない。fold 関連オプションは neovim-treesitter の新要件として treesitter.lua 側に置くため neovim-options の要件も変更しない（design D 参照）。 -->

## Impact

- 新規ファイル: `neovim/.config/nvim/lua/config/treesitter.lua`。
- 変更ファイル: `neovim/.config/nvim/lua/config/plugins.lua`（`vim.pack.add` への treesitter 追加と `require("config.treesitter")`）、`neovim/.config/nvim/nvim-pack-lock.json`（vim.pack が treesitter の revision を追記）、`neovim/README.md`（treesitter の節を追記）。
- `~/.config/nvim` はディレクトリ単位のシンボリックリンクのため新規ファイルは `stow -R` なしで反映される。
- パーサ実体は `~/.local/share/nvim/site/parser/` にコンパイルされ、repo には含めない（プラグイン本体・パーサとも data standard-path 配下。ロックファイルのみ管理）。
- ネットワーク・ビルド依存: 初回起動／更新時に GitHub から clone し、各パーサを **C コンパイラでビルド**する（`tree-sitter` CLI 不要、nvim-treesitter が C ソースをコンパイル）。`cc`/`gcc` が要る。オフラインや未ビルドでも起動が壊れないことを design で担保する。
- 既存パッケージ（vim, zsh, tmux）および neovim-options / -keymaps / -autocmds / -plugins の要件への影響なし。
