## Context

`setup-neovim-plugins`（vim.pack 土台）→ `setup-neovim-treesitter`（構文認識）に続く機能プラグイン回。環境は nvim 0.12.3。

実環境・各 README/docs で確認済みの事実:

- nvim 0.12 は組み込みで `vim.lsp.config`（table）/ `vim.lsp.enable`（function）/ `vim.lsp.completion.enable`（function）を持ち、デフォルト LSP キーマップ（`grn` 改名 / `gra` コードアクション / `grr` 参照 / `gri` 実装 / `K` ホバー等）も登録済み。
- PATH 上の言語サーバは `rust-analyzer` のみ。`lua-language-server`/`bash-language-server`/`vscode-json-language-server`/`yaml-language-server`/`taplo` は未導入。
- **mason 系**: `mason.setup()` → (`nvim-lspconfig` が rtp 上) → `mason-lspconfig.setup()` の順。`mason-lspconfig` v2 は `ensure_installed`（lspconfig サーバ名）と `automatic_enable = true`（既定）を持ち、インストール済みサーバを `vim.lsp.enable()` で自動有効化する。要件 neovim>=0.11 / mason>=2.0 / nvim-lspconfig>=2.0。`lua_ls <-> lua-language-server` の名前変換は mason-lspconfig が担う。`nvim-lspconfig` は各サーバの `lsp/*.lua` を供給し `vim.lsp.enable` がそれを使う。
- **blink.cmp**: nvim 0.10+。タグにピンすると prebuilt fuzzy バイナリを自動 DL（cargo 不要）。`setup({ keymap = { preset = 'default' }, sources = { default = {'lsp','path','snippets','buffer'} }, fuzzy = { implementation = 'prefer_rust_with_warning' } })`。capabilities は自動登録されず `require('blink.cmp').get_lsp_capabilities()` を明示的に渡す。`prefer_rust_with_warning` は DL/ロード失敗時に Lua 実装へフォールバック。

## Goals / Non-Goals

**Goals:**
- 組み込み `vim.lsp` を土台に LSP を有効化し、最小セットの言語サーバを mason で調達・自動有効化する。
- blink.cmp による補完を入れ、その capability を全サーバへ配線する。
- 「組み込み優先・薄い宣言層・専用 config モジュール」という既存路線を維持する。
- 初回オフライン・サーバ未導入・fuzzy バイナリ未取得でも nvim 起動を壊さない。

**Non-Goals:**
- フォーマッタ / linter（conform.nvim / nvim-lint）。
- friendly-snippets・追加言語サーバ・nvim-cmp。
- LSP キーマップの体系的再設計（デフォルトを活かし不足だけ補う）。
- インレイヒント・コードレンズ等の高度機能（必要時に別回）。

## Decisions

### D1: 組み込み vim.lsp.enable を土台に、サーバ調達だけ mason に任せる

設定の中心は組み込み `vim.lsp`（`vim.lsp.config` / `vim.lsp.enable`）に置く。`nvim-lspconfig` は「サーバ設定データ（`lsp/*.lua`）の供給源」として使い、その `setup()` ラッパ（旧来の `lspconfig.lua_ls.setup{}`）は使わない。mason は「バイナリ調達」、`mason-lspconfig` は「mason パッケージ名 ↔ lspconfig サーバ名の橋渡し + `automatic_enable` による `vim.lsp.enable` 呼び出し」に限定する。これで treesitter main と同じく「組み込みに委譲し、プラグインは調達と橋渡しに縮小」できる。

代替: 旧来の `lspconfig.<server>.setup{}` 方式 → 却下（0.11+ では非推奨方向で、組み込み `vim.lsp.enable` が正道）。mason 無しでサーバを brew/npm 管理 → 却下（ユーザー選択は mason。再現性が高い）。

### D2: セットアップ順序と capabilities 配線

順序に依存があるため `lsp.lua` で次の順に行う:

1. `require("mason").setup()`。
2. `vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })` … 全サーバ共通の既定 capability に blink を載せる。`get_lsp_capabilities()` は引数なしで「組み込み + blink」をマージして返す。
3. `require("mason-lspconfig").setup({ ensure_installed = {...}, automatic_enable = true })` … インストール済みサーバを `vim.lsp.enable()`。enable 時に解決される設定は `lsp/<server>.lua`（lspconfig）+ `vim.lsp.config("*")`（capabilities）+ 任意の `vim.lsp.config("<server>")` のマージなので、2 で載せた capability が確実に効く。

`completion.lua`（blink.setup）は `plugins.lua` から `lsp.lua` より先に require する。ただし capabilities は `require("blink.cmp")` さえできれば `setup` 前でも取得可能なので、順序が万一前後しても致命的ではない（堅牢側に倒す）。

### D3: blink は release tag にピンして prebuilt を得る（cargo を要求しない）

`vim.pack.add` の `version` に semver range を渡し、blink の v1 系タグにピンする（`version = vim.version.range("1")`）。タグ上では blink がランタイムで prebuilt fuzzy バイナリを自動 DL するため、`PackChanged` の build フック（cargo build）は不要。`fuzzy.implementation = "prefer_rust_with_warning"` により、DL 失敗・バイナリ不在時は警告を出して Lua 実装にフォールバックし、補完自体は動き続ける。これで「コンパイラ/Rust ツールチェーン不在でも壊れない」を満たす。

リスク: vim.pack は blobless 部分 clone + detached checkout。blink のタグ検出（`git describe` 相当）が detached でも効くかは環境依存。効かない場合は Lua フォールバックで動作は継続し、必要なら後続 change で `PackChanged` から明示 DL/build を配線する余地を残す。

代替: blink を main 追従 + `PackChanged` で `cargo build --release` → 却下（Rust ツールチェーン必須になり「薄く・壊れない」に反する）。

### D4: 補完は blink に一本化し、組み込み completion は使わない

`vim.lsp.completion.enable()` は組み込みの簡易補完で、blink と併用すると二重発火・体験の二重化を招く。本 change では補完を blink.cmp に一本化し、`vim.lsp.completion.enable` は呼ばない。

### D5: モジュール分割（completion.lua / lsp.lua）と plugins.lua レジストリ

treesitter 回の「レジストリ追加 + 専用 config」を踏襲。`plugins.lua` の `vim.pack.add` に mason.nvim / nvim-lspconfig / mason-lspconfig.nvim / blink.cmp を足し、末尾で `require("config.completion")` → `require("config.lsp")` の順に読む。LSP と補完を別モジュールにするのは関心の分離（補完エンジン差し替えや、将来 LSP 側だけ拡張する余地）のため。capabilities という結合点は D2 のとおり lsp.lua 側で解決する。

### D6: 診断表示は最小の妥当デフォルトを vim.diagnostic.config で

`vim.diagnostic.config({ virtual_text = true, severity_sort = true, ... })` 程度の最小設定を `lsp.lua` に置く。記号（sign）やフロート枠の作り込みは今回はしない（UI 回で扱える）。`neovim-options` は触らない。

### D7: LSP キーマップはデフォルト活用 + LspAttach で最小補完

nvim 0.11+ の既定（`grn`/`gra`/`grr`/`gri`/`K`、`[d`/`]d` 診断移動）を活かす。`LspAttach` autocmd（`clear=true` の専用 augroup）でバッファローカルに不足分だけ足す（例: `gd` = `vim.lsp.buf.definition`、必要なら `gD` = 宣言）。`keymaps.lua` は plugin-free のまま保ち、LSP 依存キーマップは本 capability の関心事として `lsp.lua` に置く。各 `map` に `desc` を付ける（keymaps の記述スタイル踏襲）。

### D8: 失敗・不在に強くする

`require("blink.cmp")` / `require("mason")` / `require("mason-lspconfig")` は `pcall` で保護し、未インストール（初回オフライン等）でも起動を止めない。サーバは mason が非同期で入れるため初回セッションでは LSP が付かないことがある（パーサと同様、再起動で揃う）。ランタイム（Node 等）不在のサーバはそのサーバだけ無効になり、他に波及しない。

## Risks / Trade-offs

- [blink の prebuilt DL が detached checkout で走らない可能性] → `prefer_rust_with_warning` で Lua フォールバックし補完は継続。必要なら後続で `PackChanged` から明示配線。
- [mason のサーバが各言語ランタイム（Node 等）を要求し、不在だと入らない] → 当該サーバのみ無効。README に主要サーバの前提を明記。
- [初回はサーバ DL 待ちで LSP が即座に付かない] → treesitter と同じ非同期調達の性質。再起動で揃う。
- [mason のサーバ実体はロックファイル管理外で revision 固定されない] → `ensure_installed` のリストで再現する方針を README に明記（プラグイン本体は lockfile、サーバは mason 管理という二層を明示）。
- [capabilities を `vim.lsp.config("*")` に載せる順序ミスで補完 capability が抜ける] → D2 の順序を tasks で固定し、検証で capabilities が乗ったことを確認。
- [blink デフォルトキーマップが既存マッピングと競合] → `preset = 'default'`（補完中のみ有効な挿入モードキー）で副作用は小。問題が出たら preset を見直す。

## Migration Plan

1. `lua/config/completion.lua` を作成（blink.setup）。
2. `lua/config/lsp.lua` を作成（mason.setup → `vim.lsp.config("*", capabilities)` → mason-lspconfig.setup(ensure_installed, automatic_enable) → `vim.diagnostic.config` → `LspAttach` キーマップ）。
3. `plugins.lua` の `vim.pack.add` に4プラグインを追加（blink は `version` で v1 系タグにピン）、末尾で `require("config.completion")` → `require("config.lsp")`。
4. `nvim` を起動 → clone と mason のサーバ DL、blink の prebuilt 取得が走る。`:Mason` / `:checkhealth vim.lsp` で状態確認。
5. lua ファイルを開き、`lua_ls` がアタッチし、補完（挿入モードで候補が出る）・ホバー（`K`）・診断が効くことを確認。
6. ロックファイルに4プラグインの revision が追記されたことを確認し `git add`。
7. `README.md` に LSP/補完の節（mason によるサーバ調達と再現方針、blink の prebuilt/フォールバック、キーマップ、ランタイム前提）を追記。
8. ロールバック: `plugins.lua` の4行と require 2行を戻し、`completion.lua`/`lsp.lua` を削除、`vim.pack.del({...})`、ロックファイルを `git checkout`。

## Open Questions

- なし（エンジン選定・サーバ調達・サーバセット・モジュール構成・capabilities 配線はユーザー確認および実環境 + README 調査で確定済み）。
