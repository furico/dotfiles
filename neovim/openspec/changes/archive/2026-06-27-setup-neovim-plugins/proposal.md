## Why

options / keymaps / autocmds で「素の Neovim を快適に使う」フェーズを締めた。次はプラグイン導入の土台を作る回。`neovim-autocmds` の proposal では次回を「lazy.nvim 導入回」と書いていたが、本 change では **Neovim 0.12 組み込みのパッケージマネージャ `vim.pack` を土台に方針変更する**。外部プラグインマネージャ（lazy.nvim 等）を入れずに、ランタイム標準の仕組みだけでインストール・更新・ピン留め・複数マシン再現が完結するため、依存を最小化できる。`init.lua` には既に `require("config.lazy")` を予約するコメントがあり、これを `config.plugins` に置き換えて伏線を回収する。

## What Changes

- `lua/config/plugins.lua` を新設し、`vim.pack.add({...})` でプラグインを宣言的に登録する薄い層を作る。プラグインマネージャ非依存の中立な名前として `config.plugins` を採用する（`vim.pack` 固有名は付けない）。
- `init.lua` の予約コメント `require("config.lazy")` を `require("config.plugins")` に置き換え、`options` / `keymaps` / `autocmds` の後に読み込む。
- プラグイン更新を確認バッファ経由で行うキーマップ／ユーザーコマンドを `<leader>` 名前空間に定義する。`neovim-keymaps` で「`<leader>` 系はプラグイン導入回で扱う」と先送りされていた名前空間を、ここで初めて開く。
- ロックファイル `nvim-pack-lock.json`（`vim.pack` が `~/.local/share/nvim` 配下に生成）を **Git 管理する**。dotfiles リポジトリ内の配置と stow 連携の方針は design で確定する。
- **検証用に colorscheme を 1 つ**だけ導入し（推奨 `tokyonight.nvim`、最終選定は design）、`termguicolors` と合わせて「インストール → 反映 → 起動時適用」が見た目で確認できる最小の実プラグインとする。
- スコープに**含めない**もの: LSP・補完・ファイラ・statusline・Treesitter 等の機能プラグイン、`PackChanged` build フックの本格運用、which-key 等のキーマップ基盤。これらは土台が立った後の別 change で扱う。

## Capabilities

### New Capabilities
- `neovim-plugins`: `vim.pack` を土台としたプラグイン管理基盤。`config.plugins` ローダの読み込み規約、`vim.pack.add` による宣言的登録、更新／管理用キーマップ、ロックファイルの Git 管理方針、起動時に適用される検証用 colorscheme を含む。

### Modified Capabilities
<!-- なし。neovim-keymaps は「<leader> 系を先送り」を MUST NOT として持つが、本 change の <leader> キーマップは新 capability neovim-plugins の要件として追加するものであり、keymaps 既存要件（Esc/nohlsearch・C-hjkl・ターミナル離脱・ビジュアル/検索 QoL）は一切変更しない。 -->

## Impact

- 新規ファイル: `neovim/.config/nvim/lua/config/plugins.lua`、ロックファイル（配置は design で確定）。
- 変更ファイル: `neovim/.config/nvim/init.lua`（`require("config.plugins")` の追加）、`neovim/README.md`（構成図とメモの更新）。
- `~/.config/nvim` はディレクトリ単位のシンボリックリンクのため、`plugins.lua` の新規追加は `stow -R` なしで反映される。
- プラグイン本体は `~/.local/share/nvim/site/pack/core/opt/` 配下に `vim.pack` がインストールするため、dotfiles リポジトリには含めない（ロックファイルのみ管理）。
- ネットワーク依存: 初回起動時に `vim.pack.add` が GitHub から clone する。オフライン時の挙動は design で触れる。
- 既存パッケージ（vim, zsh）および neovim-options / neovim-keymaps / neovim-autocmds の要件への影響なし。
