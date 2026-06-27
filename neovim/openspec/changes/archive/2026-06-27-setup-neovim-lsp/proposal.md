## Why

`setup-neovim-treesitter`（archive 済み）で構文認識の土台を入れた。次は編集体験の中核である **LSP（言語サーバ）と補完**を入れる回。nvim 0.12 は組み込みで近代 LSP スタック（`vim.lsp.config` / `vim.lsp.enable` / `vim.lsp.completion`、デフォルト LSP キーマップ `grn`/`gra`/`grr` 等）を備えるため、`vim.pack`・treesitter main と同じ「組み込みを土台に薄く積む」路線で実現できる。ただし PATH 上の言語サーバは `rust-analyzer` のみで lua-language-server 等は未導入のため、サーバの調達手段が要る。

## What Changes

- **サーバ調達に mason を導入**: `mason.nvim` + `nvim-lspconfig` + `mason-lspconfig.nvim`（v2）。`mason-lspconfig` の `ensure_installed` で必要なサーバを nvim 内から自動インストールし、`automatic_enable = true` でインストール済みサーバを `vim.lsp.enable()` まで自動有効化する。`nvim-lspconfig` が各サーバの `lsp/*.lua` 設定データを供給する。要件 neovim>=0.11 / mason>=2.0 / nvim-lspconfig>=2.0 を本環境（0.12.3）が満たす。
- **補完に blink.cmp を導入**: `Saghen/blink.cmp`。release tag にピンすれば prebuilt の fuzzy バイナリを自動取得する（cargo 不要）。ソースは LSP / path / snippets / buffer。`fuzzy.implementation = "prefer_rust_with_warning"` で取得失敗時も Lua 実装にフォールバックする。
- **補完 capability の配線**: `vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })` で全サーバに blink の補完 capability を載せ、`automatic_enable` 経由の `vim.lsp.enable` がそれを使う。組み込み `vim.lsp.completion.enable` は blink と重複するため使わない。
- **初期サーバ（最小セット）**: `lua_ls`, `bashls`, `jsonls`, `yamlls`, `taplo`。この dotfiles repo で実際に編集するもの中心。`ensure_installed` の1行追加で増やせる。
- **診断表示**: `vim.diagnostic.config({...})` で妥当な最小デフォルト（virtual_text 等）を設定する。
- **LSP キーマップ**: nvim 0.11+ のデフォルト（`grn`/`gra`/`grr`/`gri`/`K` 等）を活かし、`LspAttach` autocmd でバッファローカルに不足分だけ最小限補う（例 `gd` = 定義へ）。`clear=true` augroup で冪等にする。
- **モジュール構成**: treesitter 回で確立した「`plugins.lua` のレジストリに追加 + 専用 config モジュール」パターンを踏襲し、`lua/config/completion.lua`（blink.cmp）と `lua/config/lsp.lua`（mason・配線・診断・キーマップ）を新設する。
- スコープに**含めない**もの: フォーマッタ（conform.nvim）・linter（nvim-lint）・friendly-snippets・追加言語サーバ・nvim-cmp。別 change で扱う。

## Capabilities

### New Capabilities
- `neovim-lsp`: 組み込み `vim.lsp` を土台にした LSP 基盤。`mason` によるサーバ調達（`ensure_installed`）、`mason-lspconfig` の `automatic_enable` による `vim.lsp.enable()`、`nvim-lspconfig` の設定データ供給、`vim.lsp.config('*')` への補完 capability 配線、`vim.diagnostic.config` の診断表示、`LspAttach` のバッファローカルキーマップを含む。
- `neovim-completion`: `blink.cmp` による補完体験。LSP / path / snippets / buffer ソース、release tag ピンによる prebuilt fuzzy バイナリ取得と Lua フォールバック、`keymap` プリセット、LSP への capabilities 提供関数を含む。

### Modified Capabilities
<!-- なし。neovim-plugins の「vim.pack.add で宣言的に列挙」要件はそのまま満たす（4プラグインを同じレジストリに足すだけ）。neovim-keymaps は「<leader> 系・LSP 等プラグイン依存キーマップは別回」と先送りしており、本 change の LspAttach キーマップは新 capability neovim-lsp の要件として追加するため keymaps 既存要件は変更しない。 -->

## Impact

- 新規ファイル: `neovim/.config/nvim/lua/config/completion.lua`、`neovim/.config/nvim/lua/config/lsp.lua`。
- 変更ファイル: `neovim/.config/nvim/lua/config/plugins.lua`（`vim.pack.add` への4プラグイン追加と require 2行）、`neovim/.config/nvim/nvim-pack-lock.json`（revision 追記）、`neovim/README.md`（LSP/補完の節を追記）。
- `~/.config/nvim` はディレクトリ単位のシンボリックリンクのため新規ファイルは `stow -R` なしで反映される。
- サーバ実体は mason が `~/.local/share/nvim/mason/` に、プラグイン本体は `~/.local/share/nvim/site/pack/core/opt/` に置く。いずれも repo には含めない（ロックファイルのみ管理。mason のサーバは `ensure_installed` から再現）。
- ネットワーク・ビルド依存: 初回に各プラグインを clone、mason が各サーバを DL、blink が prebuilt fuzzy バイナリを DL する。`lua_ls` 等の一部サーバは Node / 各言語ランタイムを要求する（mason が解決を試みるが、ランタイム不在時はそのサーバのみ無効）。オフライン・未導入でも nvim 起動が壊れないことを design で担保する。
- 既存パッケージ（vim, zsh, tmux）および neovim-options / -keymaps / -autocmds / -plugins / -treesitter の要件への影響なし。
