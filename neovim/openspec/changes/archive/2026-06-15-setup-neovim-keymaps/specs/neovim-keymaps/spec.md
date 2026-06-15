# neovim-keymaps Specification

## Purpose

プラグインに依存しない Neovim のコア編集 keymap を定義する。nvim 0.12 のデフォルト keymap および `neovim-options` で設定済みの項目と重複させず、「素の Neovim に欠けている穴」だけを埋める。`lua/config/keymaps.lua` に定義し、薄い `init.lua` ローダから `require` 経由で読み込む。

## Requirements

### Requirement: keymaps モジュールの読み込み

`init.lua` は `lua/config/keymaps.lua` を `require` 経由で読み込まなければならない（MUST）。読み込みは `require("config.options")` の後に行う。keymap の実体定義は `init.lua` に直接書かず `keymaps.lua` に置く。

#### Scenario: keymaps モジュールが読み込まれる

- **WHEN** Neovim が起動し `init.lua` が評価される
- **THEN** `require("config.options")` に続いて `require("config.keymaps")` が評価される
- **AND** `keymaps.lua` で定義された keymap が反映される

### Requirement: keymap の記述スタイル

`keymaps.lua` は `local map = vim.keymap.set` の薄い別名で keymap を定義しなければならない（MUST）。カスタムラッパ抽象は導入しない。各マッピングには `desc` を付与する。

#### Scenario: 別名と desc

- **WHEN** `keymaps.lua` を確認する
- **THEN** `local map = vim.keymap.set` が定義されている
- **AND** 各 `map(...)` 呼び出しに `desc` を含む opts が渡されている

### Requirement: 検索ハイライト解除

normal モードの `<Esc>` で検索ハイライトを解除しなければならない（MUST）。ウィンドウ移動に `<C-l>` を割り当てることで失われるデフォルトの nohlsearch を `<Esc>` で代替する。実装は副作用を抑えるため `<cmd>nohlsearch<CR>` を用いる。

#### Scenario: Esc でハイライトが消える

- **WHEN** 何かを検索してマッチがハイライトされた状態で normal モードの `<Esc>` を押す
- **THEN** 検索ハイライトが解除される（`:nohlsearch` 相当）

### Requirement: ウィンドウ移動

normal モードの `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` で左 / 下 / 上 / 右のウィンドウへ移動できなければならない（MUST）。これは nvim デフォルト（`<C-w>h` 等）に存在しない補完である。

#### Scenario: Ctrl + hjkl でウィンドウ移動

- **WHEN** 複数のウィンドウに分割した状態で normal モードの `<C-h/j/k/l>` を押す
- **THEN** それぞれ `<C-w>h/j/k/l` と同様に隣接ウィンドウへフォーカスが移動する

### Requirement: ターミナルモード離脱

terminal モードの `<Esc><Esc>` でターミナルモードを抜けて normal モードへ移行できなければならない（MUST）。実装は `<C-\><C-n>` を用いる。

#### Scenario: 端末から normal モードへ抜ける

- **WHEN** `:terminal` 等でターミナルモードにいる状態で `<Esc><Esc>` を押す
- **THEN** ターミナルの normal モードへ移行する（`<C-\><C-n>` 相当）

### Requirement: ビジュアル/検索の操作性向上

以下の QoL keymap を設定しなければならない（MUST）。いずれも既存動作の上位互換的な挙動で、副作用が小さいものに限る。

- ビジュアル（`x` モード）の `<` / `>` を `<gv` / `>gv` にし、インデント後も選択を維持する。select-mode では定義しない。
- normal モードの `n` / `N` を `nzzzv` / `Nzzzv` にし、検索ジャンプ後にカーソル行を画面中央へ寄せ、折りたたみを展開する。

#### Scenario: インデントしても選択が維持される

- **WHEN** ビジュアルモードで複数行を選択し `>` を押す
- **THEN** 選択範囲がインデントされ、かつ選択が維持される（連続して `>` を押せる）

#### Scenario: 検索ジャンプ後に中央寄せされる

- **WHEN** `n` または `N` で次/前のマッチへジャンプする
- **THEN** カーソル行が画面中央に来る（`zz` 相当）
- **AND** マッチが折りたたみ内にある場合は展開される（`zv` 相当）

### Requirement: スコープ外項目の非導入

本 change ではプラグイン非依存のコア keymap のみを扱い、以下を導入してはならない（MUST NOT）。これらはデフォルトで充足されるか、将来の別 change で扱う。

#### Scenario: 今回入れない項目

- **WHEN** 本 change の成果物を確認する
- **THEN** nvim 0.12 デフォルトで充足される keymap（`[d`/`]d` 診断移動、`<C-w>d` 診断 float、`]b`/`[b` バッファ移動、`gcc` コメント）は再定義されない
- **AND** `clipboard="unnamedplus"`（options.lua）と重複するクリップボード系 keymap は含まれない
- **AND** 手癖変更系（`J`/`K` での選択行移動、矢印キー封印）は含まれない
- **AND** `<leader>` 系のマッピングは含まれない（which-key / プラグインフレームワークの名前空間と絡むため、プラグイン導入回で扱う）
- **AND** LSP / Telescope / ファイラ / which-key 等プラグイン依存の keymap は含まれない
