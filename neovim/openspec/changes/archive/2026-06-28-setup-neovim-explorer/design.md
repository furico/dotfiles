## Context

`setup-neovim-finder`（archive 済み）で `folke/snacks.nvim` を導入し、`finder.lua` の `require("snacks").setup({ picker = { enabled = true } })` で picker モジュールだけを有効化している。snacks の `explorer` は「picker の変装（a picker in disguise）」で、同じ `snacks.setup` と picker エンジンの上に構築されるサイドバー型ファイラ。導入済みプラグインのモジュールを1つ有効化するだけで、repo の価値観（純 Lua・build 不要・自己完結・pcall 保護・vim.pack ネイティブ）を崩さずファイラを足せる。

制約:
- `snacks.setup` は1回だけ呼ぶのが素直（複数回呼びはマージされるが分かりにくい）。現状その唯一の呼び出しが `finder.lua` にある。
- repo は「capability ごとに1つの `lua/config/<name>.lua` モジュール」を徹底している（options/keymaps/.../finder/git）。
- explorer のキーマップ・ファイル操作・git/診断表示は snacks 側の既定が十分に練られている（`replace_netrw`/`trash` 既定 true、tree/git_status/diagnostics/follow_file、sidebar レイアウト、ツリー内 a/d/r/c/m 等）。

## Goals / Non-Goals

**Goals:**
- 導入済み snacks の explorer を有効化し、`<leader>e` 開閉 / `<leader>E` 現在ファイル表示の最小導線を提供する。
- 「capability ごとに1モジュール」を保ったまま、explorer と finder で共有する `snacks.setup` を1か所に集約する。
- 未導入・オフラインでも起動を壊さない（既存方針の踏襲）。

**Non-Goals:**
- explorer のキー・formatter・レイアウトのカスタム作り込み（既定を採用）。
- snacks の picker / explorer 以外のモジュール有効化（dashboard/notifier/scroll/indent 等）。
- oil / neo-tree / mini.files 等の別ファイラ、`vim.pack.add` への新規プラグイン追加。
- which-key グループの新設（`<leader>e`/`<leader>E` は単独キー）。

## Decisions

### 決定1: `snacks.setup` を `snacks.lua` に切り出す（finder.lua から移管）

explorer は picker と同じ `snacks.setup` を共有する。setup を `finder.lua` に残したまま explorer を `explorer.lua` で有効化しようとすると、(a) `explorer.lua` から2回目の setup を呼ぶ（重複・順序依存）か、(b) explorer の有効化フラグだけ finder.lua に逆流させる（capability のねじれ）かになる。どちらも避けるため、**中央モジュール `lua/config/snacks.lua` を新設**して `snacks.setup({ picker = { enabled = true }, explorer = { enabled = true } })` を1か所に集約する。`finder.lua` と `explorer.lua` は各自のキーマップだけを持つ薄いモジュールになる。

- 代替案A（finder.lua に explorer も全部書く）: モジュール1つで済むが、「finder」モジュールに explorer capability が混在し、repo の1capability=1モジュール規律に反する。却下。
- 代替案B（explorer.lua で2回目の setup を呼ぶ）: setup の呼び出しが2か所に分散し、適用順・マージ挙動が読みにくい。却下。
- 採用案（snacks.lua 集約）: setup の単一呼び出しを保ちつつ capability を綺麗に分離。読み込み順も明示できる。

### 決定2: 読み込み順は snacks（setup）→ finder/explorer（keymap）

`plugins.lua` の個別設定 require 群を `require("config.snacks")` → `require("config.finder")` → `require("config.explorer")` の順にする。キーマップは押下時に snacks を遅延参照する（finder の `pick()` ヘルパと同型）ため厳密な順序依存は無いが、「setup が先・利用が後」を読み手に明示する。

### 決定3: explorer / picker source の既定をそのまま採用

`replace_netrw = true`（`nvim <dir>` で explorer が開く。autocmds が既に `oil://` 等 URI バッファを想定しており netrw 置換と整合）、`trash = true`（削除をゴミ箱へ。環境に `trash` コマンド導入済みのため即動作、未導入時も完全削除へフォールバック）。picker source 側の `tree`/`git_status`/`diagnostics`/`follow_file`/sidebar レイアウトも既定のまま。本 change ではキーや見た目をカスタムしない（必要が出たら別途）。

### 決定4: キーマップは単独キー2つ、which-key グループ非新設

`<leader>e`=開閉（`require("snacks").explorer()`）、`<leader>E`=現在ファイル表示（`require("snacks").explorer.reveal()`）。`<leader>f`=find 名前空間と衝突しない単独キーで、`desc` がそのまま which-key に出るためグループ登録（`ui.lua` の `wk.add`）は不要。ツリー内のファイル操作キー（a/d/r/c/m 等）は snacks 既定に委ね再定義しない。

## Risks / Trade-offs

- [setup 移管で finder の挙動が変わる] → `snacks.lua` の setup は既存の `picker = { enabled = true }` を含めて移すだけ。`finder.lua` のキーマップ（遅延参照）は不変。起動して `<leader>ff` 等が従来通り動くこと、`neovim-finder` のデルタ spec（picker と explorer の有効化）を満たすことで担保。
- [`replace_netrw=true` が netrw 前提の挙動を壊す] → repo 内に netrw 依存の設定は無く、autocmds は既に URI バッファを想定済み。`nvim <dir>` の挙動が explorer に変わるのみで実害は小さい。違和感が出れば `explorer = { replace_netrw = false }` に下げられる。
- [`trash` コマンド非依存環境での誤完全削除] → snacks は trash コマンド不在時に完全削除へフォールバックする設計。当環境は `trash`/`gio` 導入済みでゴミ箱送りが効く。README に挙動を明記する。
- [未導入（初回オフライン）での起動] → `snacks.lua`・`finder.lua`・`explorer.lua` の require と snacks 参照はすべて `pcall` 保護。ファイラ無しで起動・編集を継続する（spec のシナリオで担保）。
