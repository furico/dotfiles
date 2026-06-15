## Why

`setup-neovim-options` で基本オプションと薄い `init.lua` ローダ構成は確定したが、keymap は意図的にスコープ外として「将来の別 change で扱う」と明記していた。素の Neovim 運用を一段快適にするため、プラグインに依存しないコア編集 keymap をゼロベースで追加する。`init.lua` には既に `require("config.keymaps")` の置き場所がコメントで予約されており、その実体を埋める。

## What Changes

- `lua/config/keymaps.lua` を新設し、プラグイン非依存のコア keymap を定義する。
- `init.lua` のコメントアウトされた `require("config.keymaps")` を有効化する。
- 書き方は `local map = vim.keymap.set` の薄い別名を使い、各マッピングに `desc` を付与する（将来 which-key 導入時の先行投資）。カスタムラッパは作らない。
- 採用する keymap:
  - **Tier 1（コア）**: `<Esc>`=`:nohlsearch`、ウィンドウ移動 `<C-h/j/k/l>`、ターミナル離脱 `<Esc><Esc>`=`<C-\><C-n>`
  - **Tier 2（QoL）**: ビジュアルのインデント維持 `<`/`>`=`<gv`/`>gv`、検索ジャンプの中央寄せ `n`/`N`=`nzzzv`/`Nzzzv`
- 今回のスコープに**含めない**もの:
  - nvim 0.12 のデフォルトで既にカバーされる keymap（`[d`/`]d` 診断移動、`<C-w>d` 診断 float、`]b`/`[b` バッファ移動、`gcc` コメント）
  - `clipboard="unnamedplus"`（options.lua で設定済み）と重複するクリップボード系 keymap
  - 手癖変更系（`J`/`K` での選択行移動、矢印キー封印）
  - `<leader>` 系のマッピング全般。leader マップは which-key やプラグインフレームワーク（LazyVim 等）の名前空間と密接に絡むため、プラグイン導入回で名前空間ごと設計する。本 change ではプラグイン非依存のコア keymap のみを扱う。
  - LSP / Telescope / ファイラ等プラグイン導入時に定義する keymap レイヤ

## Capabilities

### New Capabilities
- `neovim-keymaps`: プラグイン非依存のコア編集 keymap（ウィンドウ移動・検索ハイライト解除・ターミナル離脱・ビジュアル/検索の QoL）と、それを読み込む `init.lua` ローダ更新。

### Modified Capabilities
<!-- なし（neovim-options の既存要件は変更しない。init.lua への require 追加は「将来のモジュール追加に耐える構成」シナリオの想定どおりの拡張） -->

## Impact

- 新規ファイル: `neovim/.config/nvim/lua/config/keymaps.lua`。
- 変更ファイル: `neovim/.config/nvim/init.lua`（`require("config.keymaps")` の行を追加）。
- stow 済みであればシンボリックリンク経由で即反映される。新規リンク作成は不要（`keymaps.lua` は既存の `lua/config/` ディレクトリ配下に追加されるため `~/.config/nvim/lua/config/keymaps.lua` として参照される）。
- 既存パッケージ（vim, zsh）および neovim-options の要件への影響なし。
