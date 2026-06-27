## Context

`setup-neovim-plugins`（archive 済み）で `vim.pack` の宣言層 `config.plugins` が立ち、検証用 colorscheme が動いている。本 change はその上の最初の機能プラグイン回。環境は nvim 0.12.3。

実環境・main ブランチ README で確認済みの事実:

- `nvim-treesitter` main は最低 **nvim 0.12.0** 必須。組み込み `vim.treesitter` に委譲する書き直し版で、プラグインの役割は「パーサのインストーラ + query/parser revision 供給」に縮小。
- API: `require("nvim-treesitter").setup{ install_dir = ... }`（任意）、`require("nvim-treesitter").install({...})`（**非同期**、`:wait(ms)` で同期化）、コマンド `:TSInstall` / `:TSUpdate`。
- ハイライトは**自前配線**: `FileType` で `vim.treesitter.start()`。インデント（実験的）: `vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"`。折りたたみ: `foldexpr = vim.treesitter.foldexpr()` + `foldmethod=expr`。
- プラグイン更新時は **必ず `:TSUpdate`**（parser と query の整合）。main は **lazy-loading 非対応**。
- 各パーサは **C ソースをコンパイル**して `install_dir/parser/*.so` に置かれる（C コンパイラが要る）。nvim 0.12 同梱は c/lua/markdown/markdown_inline/query/vim/vimdoc の7パーサ + 対応 query のみ。
- `vim.pack` の `PackChanged` イベントの `ev.data` は `{ kind = "install"|"update"|"delete", path, active, spec }`（pack.txt で確認済み）。`vim.pack.add` の default は repo の default ブランチ（nvim-treesitter は **master**）。

## Goals / Non-Goals

**Goals:**
- main ブランチの nvim-treesitter を `vim.pack` で導入し、構文ハイライトと折りたたみを実用化する。
- パーサのインストール／更新を `PackChanged` build フックで自動化し、parser と query を常に整合させる。
- 設定をモジュール分離し、以降のプラグイン追加が同じパターンで積める形にする。
- 初回オフライン・パーサ未ビルド・コンパイラ不在でも nvim の起動を壊さない。

**Non-Goals:**
- LSP・補完・他の機能プラグイン（別 change）。
- treesitter の追加モジュール（`incremental_selection`・textobjects 等）。
- パーサ実体や query の repo への取り込み（data path 配下のまま、ロックファイルのみ管理）。
- 全言語の網羅。最小セットで始め、必要時に1行で足す。

## Decisions

### D1: main ブランチを `version = "main"` で明示ピン

nvim-treesitter の repo default ブランチは legacy の `master`。`vim.pack.add` で `version` を省くと master が入ってしまうため、`{ src = ".../nvim-treesitter", version = "main" }` と明示ピンする。これは「組み込み `vim.treesitter` に委譲する」本 change の前提そのもの。0.12.0+ 必須要件は本環境（0.12.3）が満たす。

代替: master ブランチ（`configs.setup` 一括・自動ハイライト）→ 却下。legacy（凍結）であり、`vim.pack`/組み込み優先という本 repo の方針と噛み合わないため。

### D2: レジストリ（plugins.lua）と専用 config（treesitter.lua）の分離

`neovim-plugins` spec は「`plugins.lua` の `vim.pack.add` で宣言的に列挙」を要件に持つ。これを守り、treesitter も同じ `vim.pack.add` 呼び出しに足して「何を入れているか」を中央集約する。一方、treesitter 固有の設定（install リスト・build フック・ハイライト/fold/indent 配線）は新モジュール `lua/config/treesitter.lua` に出し、`plugins.lua` から `require("config.treesitter")` する。以降のプラグインも「レジストリに1行 + 専用 config モジュール」で増やせる。

### D3: ハイライトは FileType autocmd + `vim.treesitter.start()`、clear=true augroup

main では `highlight.enable` の魔法が無いので自前で配線する。`autocmds.lua` と同じく `vim.api.nvim_create_augroup(name, { clear = true })` で包み、再ソースしても二重登録しない。`FileType` のコールバックで `vim.treesitter.start()` を呼ぶが、パーサ未導入の filetype では例外を投げるため **`pcall` で保護**する（初回オフライン・未ビルドでも他の起動処理を止めない）。pattern は対象言語に限定せず `FileType *` でも `pcall` 失敗時に無害にできるが、無用な試行を避けるため初期言語セットに対応する filetype 群へ限定する。

### D4: PackChanged build フック + 起動時 install（冪等）

`setup-neovim-plugins` で先送りした build フックの初実用。`PackChanged` の autocmd を専用 augroup で登録し、`ev.data.spec.name == "nvim-treesitter"` かつ `ev.data.kind` が `install` / `update` のとき、対象言語の `require("nvim-treesitter").install(langs)` と `:TSUpdate` を走らせて parser を（再）コンパイル・query と整合させる。フックがプラグインのコードに依存するので、必要なら `ev.data.active` を見て `vim.cmd.packadd("nvim-treesitter")` で先に読み込む（pack.txt のフック例に準拠）。

加えて起動時にも `require("nvim-treesitter").install(langs)` を**非同期**で呼ぶ。`install` は未導入分のみ入れる冪等動作なので、初回や言語追加時に欠けたパーサを埋める。起動をブロックしないよう `:wait` は付けない（同期化はスクリプト検証時のみ）。

### D5: 折りたたみは「開いた状態で始まる」よう foldlevel をガード、設定は treesitter.lua に置く

`foldexpr = vim.treesitter.foldexpr()` + `foldmethod=expr` を有効にすると、ファイルを開いた瞬間に深い階層まで折りたたまれて驚く。これを避けるため `foldlevelstart = 99`（新規ウィンドウは展開済みで開始）を設定する。fold 関連オプションは **`neovim-options` の要件を変えないため options.lua には足さず**、本 capability の関心事として `treesitter.lua` に置く。`foldexpr`/`foldmethod` は treesitter が有効なバッファに限定したいので、D3 の `FileType` コールバック内でウィンドウローカル（`vim.wo[0][0]`）に設定する。これにより treesitter 非対象ファイルは既定の手動 fold のまま。

### D6: 実験的インデントは有効化するが「最も外しやすい一手」として隔離

main の `indentexpr`（`v:lua.require'nvim-treesitter'.indentexpr()`）は実験的。D3 の `FileType` コールバック内でバッファローカル（`vim.bo.indentexpr`）に設定して有効化する。`options.lua` の `smartindent=true` はグローバル既定として残り、`indentexpr` が設定されたバッファではそちらが優先される（Vim の挙動）。実験的ゆえ誤インデントの可能性があるため、`treesitter.lua` の1箇所で on/off できるよう隔離し、問題が出たら行削除で即無効化できる形にする。spec では highlight/fold を MUST、indent を「有効化する（実験的）」として、振る舞いの厳密さは highlight/fold に寄せる。

### D7: 初期言語セットは dotfiles 中心、組み込み済みでも nvim-treesitter で入れる

`lua, vim, vimdoc, query, bash, markdown, markdown_inline, json, yaml, toml, diff, gitcommit`。この repo で実際に編集する Lua / シェル / 各種設定 / README / git バッファを優先。c/lua/markdown 等は nvim に同梱パーサがあるが、**main の query と version 整合を取るため nvim-treesitter 経由で install_dir に入れる**（同梱版と nvim-treesitter の query がずれてハイライトが崩れるのを防ぐ）。リストは `treesitter.lua` のテーブル1箇所で管理し、追加は1行。

### D8: 失敗・不在に強くする（pcall とコンパイラ前提の明示）

初回ネットワーク不通・パーサ未ビルド・`cc` 不在でも起動を壊さない。`require("nvim-treesitter")` と `vim.treesitter.start()` は `pcall` で保護し、失敗時は黙ってデフォルト（正規表現ハイライト）にフォールバックする。C コンパイラ必須である旨は README に明記する（macOS は Xcode CLT、Linux は gcc/clang）。

## Risks / Trade-offs

- [main ブランチは発展途上で API が動きうる] → 設定を `treesitter.lua` に隔離。`install`/`setup`/`indentexpr` 等は実装直前に現物 README で再確認してから書く。変更が来ても1ファイルで吸収。
- [実験的 indent が誤インデントを起こす] → D6 のとおり1箇所で隔離。問題時は行削除で smartindent 既定に戻せる。
- [C コンパイラ不在の環境でパーサがビルドできない] → 起動は pcall で守られる。README に前提を明記。CI 的な headless 検証では cc 前提。
- [PackChanged フックが update 時にプラグイン未ロードで失敗] → `ev.data.active` を見て `packadd` してから叩く（pack.txt 準拠）。
- [foldexpr 有効化で既存の編集感覚が変わる] → `foldlevelstart=99` で展開開始にし、treesitter バッファ限定で適用。非対象ファイルは不変。
- [起動時 install の非同期コンパイルが裏で走り CPU を使う] → 初回／言語追加時のみ。常時は未導入分だけなので no-op。

## Migration Plan

1. `lua/config/treesitter.lua` を作成（install リスト、`PackChanged` build フック、`FileType` ハイライト + fold/indent 配線、`foldlevelstart`）。
2. `lua/config/plugins.lua` の `vim.pack.add` に `{ src = ".../nvim-treesitter", version = "main" }` を足し、末尾で `require("config.treesitter")`。
3. `nvim` を起動 → 初回 clone とパーサのビルドが走り、対象ファイルで treesitter ハイライトが付くことを確認。
4. ロックファイルに nvim-treesitter の revision が追記されることを確認し `git add`。
5. fold（`zc`/`zo`）と、開いた直後に折りたたまれていないこと、実験的 indent の挙動を確認。
6. `README.md` に treesitter の節（main ブランチ採用理由、build フック、C コンパイラ前提、言語追加の仕方）を追記。
7. ロールバック: `plugins.lua` の treesitter 行と `require` を戻し、`treesitter.lua` を削除、`vim.pack.del({ "nvim-treesitter" })`、ロックファイルを `git checkout`。

## Open Questions

- なし（ブランチ選定・モジュール構成・言語セット・fold/indent の扱いはユーザー確認および実環境 + README 調査で確定済み）。
