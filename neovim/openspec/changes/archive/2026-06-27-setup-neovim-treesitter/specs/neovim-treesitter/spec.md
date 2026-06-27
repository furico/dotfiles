## ADDED Requirements

### Requirement: nvim-treesitter（main ブランチ）の導入

`nvim-treesitter` を `vim.pack` で導入しなければならない（MUST）。導入は **main ブランチ**を `version = "main"` で明示ピンして行わなければならない（MUST）。repo の default ブランチは legacy の `master` であり、ピンを省くと意図しない master が入るため、ピンを省いてはならない（MUST NOT）。登録は `neovim-plugins` の宣言レジストリ（`plugins.lua` の `vim.pack.add`）に追加する。

#### Scenario: main ブランチがピンされて入る

- **WHEN** `plugins.lua` の `vim.pack.add` を確認する
- **THEN** `nvim-treesitter` のソースが `version = "main"` 付きで登録されている

#### Scenario: 初回起動でインストールされる

- **WHEN** `nvim-treesitter` 未インストールの状態で Neovim を起動する（ネットワーク到達可能）
- **THEN** `vim.pack` が main ブランチを clone し、プラグインがランタイムから利用可能になる

### Requirement: treesitter 設定モジュールの分離と読み込み

treesitter 固有の設定は専用モジュール `lua/config/treesitter.lua` に置き、`lua/config/plugins.lua` から `require` 経由で読み込まなければならない（MUST）。treesitter の設定実体を `plugins.lua` に直接展開してはならない（MUST NOT。`plugins.lua` は `vim.pack.add` レジストリと最小初期化に保つ）。

#### Scenario: 専用モジュールが読み込まれる

- **WHEN** Neovim が起動し `config.plugins` が評価される
- **THEN** `require("config.treesitter")` が評価され、treesitter の設定が適用される

#### Scenario: 設定実体は treesitter.lua にある

- **WHEN** `plugins.lua` を確認する
- **THEN** install リスト・build フック・ハイライト/fold/indent 配線は `plugins.lua` に書かれておらず `treesitter.lua` にある

### Requirement: 構文ハイライトの有効化

対象言語のバッファで treesitter による構文ハイライトを有効化しなければならない（MUST）。main ブランチでは自前配線が必要なため、`FileType` autocmd で `vim.treesitter.start()` を呼ぶ。autocmd は `clear = true` の専用 augroup でグループ化し、再ソースで二重登録されないようにしなければならない（MUST）。パーサ未導入等で `vim.treesitter.start()` が失敗しても起動・編集を中断してはならない（MUST。`pcall` 等で保護する）。

#### Scenario: 対象ファイルでハイライトが付く

- **WHEN** パーサが導入済みの対象言語ファイル（例: lua）を開く
- **THEN** `vim.treesitter.start()` が呼ばれ、treesitter による構文ハイライトが適用される

#### Scenario: パーサ未導入でも壊れない

- **WHEN** パーサが無い状態（初回オフライン・未ビルド等）で対象ファイルを開く
- **THEN** ハイライト開始は失敗するが Neovim の起動・編集は継続する（デフォルトのハイライトにフォールバック）

#### Scenario: 再ソースで二重登録されない

- **WHEN** 設定を再ソースする
- **THEN** 同一 augroup の既存 autocmd がクリアされてから再登録され、重複しない

### Requirement: パーサの install と PackChanged build フック

対象言語のパーサを `nvim-treesitter` の install 機構で導入・更新しなければならない（MUST）。`vim.pack` の `PackChanged` autocmd で、`nvim-treesitter` の `install` / `update` 時に対象言語の install と `:TSUpdate` を走らせ、parser と query を整合させなければならない（MUST）。加えて起動時に欠けているパーサを冪等に補うため、`require("nvim-treesitter").install(langs)` を**非同期**で呼ぶ（起動をブロックしない）。対象言語は単一のテーブルで一元管理し、追加が容易でなければならない（MUST）。

#### Scenario: 更新時に parser が同期される

- **WHEN** `nvim-treesitter` が更新される（`PackChanged` の kind が update）
- **THEN** 対象言語の install と `:TSUpdate` が走り、parser が query と整合する版に更新される

#### Scenario: 起動時に欠けたパーサを補う

- **WHEN** 対象言語の一部パーサが未導入の状態で Neovim を起動する
- **THEN** 非同期 install が走り、未導入分のみがインストールされる（導入済みは再取得しない）

#### Scenario: 言語追加が一箇所

- **WHEN** 対象言語を増やしたい
- **THEN** `treesitter.lua` の言語テーブルに 1 エントリ足すだけで対象に含まれる

### Requirement: 折りたたみの有効化

treesitter が有効なバッファで treesitter ベースの折りたたみを有効化しなければならない（MUST）。`foldexpr` に `vim.treesitter.foldexpr()` を、`foldmethod` を `expr` に設定する。設定は treesitter 対象バッファ／ウィンドウに限定し、非対象ファイルの折りたたみ挙動を変えてはならない（MUST NOT）。ファイルを開いた直後に折りたたまれた状態にならないよう、`foldlevelstart` を展開側の値（例: 99）にしなければならない（MUST）。fold 関連オプションは `neovim-options` の要件を変えないため `options.lua` ではなく `treesitter.lua` に置く。

#### Scenario: 対象ファイルで折りたためる

- **WHEN** treesitter が有効な対象ファイルを開く
- **THEN** `foldmethod=expr` / `foldexpr=treesitter` が設定され、構文構造に沿って `zc` / `zo` で折りたためる

#### Scenario: 開いた直後は展開されている

- **WHEN** 対象ファイルを開く
- **THEN** 折りたたまれずに全展開で表示される（`foldlevelstart` により）

#### Scenario: 非対象ファイルは不変

- **WHEN** treesitter 非対象のファイルを開く
- **THEN** 折りたたみは既定（手動）のままで、treesitter foldexpr は設定されない

### Requirement: 実験的インデントの有効化

treesitter が有効なバッファで main の実験的インデント（`indentexpr`）を有効化する（SHOULD）。`FileType` コールバック内でバッファローカルに `indentexpr` を設定し、`treesitter.lua` の1箇所で on/off を切り替えられるよう隔離しなければならない（MUST）。実験的のため、誤インデント時は当該設定を外してグローバル既定（`smartindent`）へ戻せること。

#### Scenario: 対象バッファで indentexpr が設定される

- **WHEN** treesitter が有効な対象ファイルを開く
- **THEN** バッファローカルに treesitter の `indentexpr` が設定される

#### Scenario: 一箇所で無効化できる

- **WHEN** `treesitter.lua` の indent 設定箇所を外す
- **THEN** 対象バッファは `indentexpr` を持たず、`options.lua` の `smartindent` 既定で動く

### Requirement: スコープ外項目の非導入

本 capability は treesitter のハイライト・折りたたみ・（実験的）インデントのみを扱い、以下を導入してはならない（MUST NOT）。これらは別 change で扱う。

#### Scenario: 今回入れない項目

- **WHEN** 本 capability の成果物を確認する
- **THEN** LSP・補完・他の機能プラグインは含まれない
- **AND** treesitter の `incremental_selection` 等の追加モジュールや textobjects は含まれない
- **AND** パーサ実体・query はリポジトリに含めない（data standard-path 配下に置き、ロックファイルのみ管理する）
