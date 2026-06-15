## Context

`setup-neovim-options`（archive 済み）で、薄い `init.lua` ローダ + `lua/config/` 分割構成・leader（`mapleader=" "`, `maplocalleader="\\"`）・基本オプションが確定済み。keymap は同 change の spec で明示的にスコープ外とされ、本 change がその後続にあたる。

環境は nvim 0.12.x。0.12 はプラグイン不要のデフォルト keymap を多数標準装備しており（`[d`/`]d`、`<C-w>d`、`]b`/`[b`、`gcc` 等）、「素の vim でやりがちな自作 keymap」の多くが既に不要になっている。本 change は「デフォルトに欠けていて、プラグイン不要で、ほぼ全員が入れるもの」だけを薄く入れ、後はプラグイン導入時のレイヤに委ねる方針を取る。

## Goals / Non-Goals

**Goals:**
- プラグイン非依存で「素の Neovim に欠けている穴」を埋めるコア keymap を確定する。
- 1 枚 `keymaps.lua` ＋ `local map = vim.keymap.set` の薄い構成で、後から育てやすくする。
- 各マッピングに `desc` を付け、将来 which-key を入れた瞬間に説明が出る状態にする。

**Non-Goals:**
- nvim 0.12 デフォルトと重複する keymap の再定義。
- 手癖変更系（`J`/`K` 行移動・矢印封印）の導入。
- LSP / Telescope / ファイラ / which-key 等プラグイン依存の keymap レイヤ。
- カスタム keymap ヘルパ（`map(mode, lhs, rhs, opts)` 抽象）の導入。

## Decisions

### D1: 「デフォルトに無い穴」だけを埋める最小主義

nvim 0.12 のデフォルト（`[d`/`]d` 診断移動、`<C-w>d` 診断 float、`]b`/`[b` バッファ移動、`gcc` コメント）と、options.lua の `clipboard="unnamedplus"` を差し引くと、プラグインなしで本当に欠けているのはごく少数。これらだけを Tier 1 とする。デフォルトの再発明を避けることで、育てる土台を汚さない。

代替案: kickstart / LazyVim の keymap をまるごと写経 → 却下（プラグイン前提のものが混ざり、デフォルトと重複し、不要な認知負荷になる）。

### D2: `<C-l>` をウィンドウ移動に割り当てるため `<Esc>` に nohlsearch を移す

nvim デフォルトの `<C-l>`（normal）は「再描画 + nohlsearch」。ウィンドウ移動 `<C-h/j/k/l>` を入れると `<C-l>` がこの役割を失う。そこで検索ハイライト解除を `<Esc>` に割り当てる。Tier 1 の3つ（`<Esc>`=nohlsearch / `<C-hjkl>` / `<Esc><Esc>` 端末離脱）はこの依存関係でセット運用が自然。nohlsearch は副作用を抑えるため `<cmd>nohlsearch<CR>` で実装する。

### D3: ラッパは作らず `local map = vim.keymap.set` ＋ `desc` 付与

options.lua の `local o = vim.o` と対称な薄い別名にする。カスタムラッパ抽象は現在の規模では過剰。`desc` は今のうちから全マッピングに付け、which-key 導入時にゼロコストで効くようにする（先行投資）。

### D4: Tier 2 は QoL 系のみ採用、手癖変更系は見送り

採用: `<`/`>`=`<gv`/`>gv`（インデント後も選択維持）、`n`/`N`=`nzzzv`/`Nzzzv`（検索ジャンプ後に中央寄せ＋折返し展開）。いずれも既存動作の上位互換に近く、副作用が小さい。
見送り: `J`/`K` での選択行移動（`J` の本来動作を奪う）、矢印キー封印（手癖矯正系）。素から育てる段階では事故りやすく、必要になってから足せばよい。

### D5: ビジュアル系は select-mode を避け `x`（visual）モードで定義

`<`/`>` のインデント維持は select-mode（`v` 指定に含まれる）で発火するとタイプ文字が選択を置換するなど直感に反する。ビジュアルモード限定の `x` で定義する。

### D6: `keymaps.lua` 新設 ＋ `init.lua` の require 追加で薄いローダ構成を実証

`init.lua` に既にコメントで予約されている `require("config.keymaps")` を有効化する。これは neovim-options spec の「将来のモジュール追加に耐える構成」シナリオ（require 行追加だけで拡張できる）の最初の実例にあたる。

## Risks / Trade-offs

- [`<C-h/j/k/l>` が将来プラグイン（tmux-navigator 等）や端末側のキーと衝突しうる] → 今回プラグインは無く衝突しない。導入時に再調整する旨を残す。
- [`<Esc>`=nohlsearch がマッピング待ちや他の Esc 連鎖に干渉する懸念] → `<cmd>` 実装で副作用を最小化。ターミナルの `<Esc><Esc>` は別モード（t）なので干渉しない。
- [stow 済み環境で `keymaps.lua` を後から追加した場合のリンク] → `lua/config/` ディレクトリ自体が既にリンクされていれば新ファイルも参照される。されていなければ `stow -R neovim` で再展開する（Migration Plan 参照）。

## Migration Plan

1. `neovim/.config/nvim/lua/config/keymaps.lua` を作成。
2. `neovim/.config/nvim/init.lua` に `require("config.keymaps")` を追加。
3. `~/.config/nvim/lua/config/keymaps.lua` がリンク経由で参照されることを確認（必要なら `stow -R neovim` で再展開）。
4. `nvim` を起動しエラーが出ないこと、各 keymap が機能することを確認。
5. ロールバック: `keymaps.lua` を削除し `init.lua` の require 行を戻す（または `stow -D neovim`）。

## Open Questions

- なし（採用 keymap・モード・書き方は探索フェーズで確定済み）。
