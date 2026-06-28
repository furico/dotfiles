# neovim

Neovim の設定。GNU Stow で XDG Base Directory 配置（`~/.config/nvim/`）に展開する。

## 構成

```
neovim/
└── .config/nvim/
    ├── init.lua                 薄いローダ。require を順に並べるだけ
    ├── nvim-pack-lock.json      vim.pack のロックファイル（自動生成・要追跡）
    └── lua/config/
        ├── options.lua          基本オプション + leader
        ├── keymaps.lua          プラグイン非依存のコア keymap
        ├── autocmds.lua         プラグイン非依存の autocmd
        ├── plugins.lua          vim.pack によるプラグイン管理（レジストリ）
        ├── treesitter.lua       nvim-treesitter（main）の設定
        ├── completion.lua       blink.cmp（補完）の設定
        ├── lsp.lua              LSP（mason + 組み込み vim.lsp）の設定
        ├── ui.lua               colorscheme/statusline/インデント/which-key
        ├── git.lua              gitsigns（git 統合）の設定
        └── finder.lua           snacks.picker（fuzzy finder）の設定
```

設定は「`plugins.lua` の `vim.pack.add` レジストリにプラグインを足す + 専用 config
モジュール（例 `treesitter.lua`）を `require` する」パターンで増やす。

`init.lua` はロード順を決めるだけの薄い層。各設定の実体は `lua/config/` 配下の
モジュールに置き、`init.lua` は `require` 行を並べるだけで拡張できる。

## プラグイン管理

Neovim 0.12 組み込みの `vim.pack` を土台にする（lazy.nvim 等の外部マネージャは
使わない）。プラグインは `lua/config/plugins.lua` の `vim.pack.add({...})` で
宣言的に列挙する。

- プラグイン実体は `~/.local/share/nvim/site/pack/core/opt/` に入り、リポジトリ
  には含めない。別マシンではロックファイルの revision から再現される。
- 更新: `<leader>pu`（`vim.pack.update()`、別タブの確認バッファで `:write` 確定 /
  `:quit` 破棄）。現状確認: `<leader>ps`（オフライン）。

### ロックファイル

`nvim-pack-lock.json` は `vim.pack` が `~/.config/nvim/` 直下に**自動生成**する。
`~/.config/nvim` は本リポジトリへの folded シンボリックリンクのため、実体は
`neovim/.config/nvim/nvim-pack-lock.json`（リポジトリ内）に落ちる。複数マシンで
revision を再現するため **Git で追跡する**。手編集はせず、更新は `vim.pack.update()`
の確認バッファ経由でのみ行う。stow のリンク対象ではない（folded ディレクトリ内の
実ファイル）ため `.stowrc` への記載は不要。

## Treesitter

構文ハイライトと折りたたみは `nvim-treesitter` の **main ブランチ**で行う。main は
組み込み `vim.treesitter` に土台を委譲する書き直し版で、`vim.pack` 同様「組み込みを
土台に薄く積む」方針と一致する（最低 nvim 0.12.0 必須）。設定は `treesitter.lua` に
集約。

- **ブランチ**: repo の default は legacy の `master` のため、`plugins.lua` の
  `vim.pack.add` で `version = "main"` を明示ピンしている（外すと master が入る）。
- **パーサのビルド**: パーサは C ソースをコンパイルして
  `~/.local/share/nvim/site/parser/` に入る。**C コンパイラが要る**（macOS は Xcode
  Command Line Tools、Linux は gcc/clang）。repo には含めない。
- **更新フック**: `vim.pack` の `PackChanged` で、nvim-treesitter の install/update 時に
  パーサの install と `:TSUpdate` を走らせ、parser と query を整合させる。起動時にも
  非同期で欠けたパーサを補う（冪等）。
- **対象言語の追加**: `treesitter.lua` の `langs` テーブルに 1 行足すだけ。
- **fold / indent**: 折りたたみは treesitter ベース（`foldlevelstart=99` で開いた直後は
  全展開）。インデントは main の実験的 `indentexpr` を有効化しており、誤動作時は
  `treesitter.lua` の `enable_indent` を `false` にすれば `smartindent` 既定へ戻る。
- 未ビルド・オフライン・コンパイラ不在でも起動は壊れない（利用箇所を pcall で保護し、
  デフォルトのハイライトへフォールバック）。

## LSP・補完

設定の中心は nvim 0.12 組み込みの `vim.lsp`（`vim.lsp.config` / `vim.lsp.enable`、
デフォルト LSP キーマップ `grn`/`gra`/`grr`/`K` 等）。プラグインは調達と橋渡しに徹する。

- **サーバ調達 = mason**: `lsp.lua` の `ensure_installed`（lspconfig サーバ名）を
  `mason.nvim` が `~/.local/share/nvim/mason/` に取得し、`mason-lspconfig` の
  `automatic_enable` が `vim.lsp.enable()` まで自動で行う。`nvim-lspconfig` は各サーバの
  `lsp/*.lua` 設定データ供給源。初期サーバは `lua_ls` / `bashls` / `jsonls` / `yamlls` /
  `taplo`（追加は `ensure_installed` に1行）。**サーバ実体は repo に含めず、リストから
  再現する**（プラグイン本体は lockfile、サーバは mason という二層）。
- **初回**: サーバは初回の対話起動で `ensure_installed` により入る（mason-lspconfig は
  ヘッドレス時は自動インストールしない仕様）。導入完了後にアタッチする。
- **ランタイム前提**: `bashls`/`jsonls`/`yamlls` は Node を要求する。不足するサーバは
  そのサーバだけ無効になり、他へは波及しない。
- **補完 = blink.cmp**: ソースは LSP / path / snippets / buffer。release tag（v1 系）に
  ピンして **prebuilt の fuzzy バイナリを自動取得**（cargo 不要）。取得失敗時は
  `prefer_rust_with_warning` で Lua 実装にフォールバックし補完は動き続ける。補完 capability は
  `require("blink.cmp").get_lsp_capabilities()` を `vim.lsp.config("*")` に載せて全サーバへ配線。
- **キーマップ**: 0.11+ のデフォルトを活かし、`LspAttach` で `gd`（定義へ）/ `gD`（宣言へ）
  だけ補う。診断表示は `vim.diagnostic.config`（virtual_text 等）。
- 未インストール・オフライン・ランタイム不在でも起動は壊れない（require を pcall で保護）。

## UI・配色・git

見た目と操作性の層。いずれも純 Lua で **build 不要**、`vim.pack.add` は `version` を
省略して default ブランチを使う。`ui.lua`（配色・statusline・インデント・which-key）と
`git.lua`（gitsigns）に分ける。require はすべて pcall 保護で、未導入でも起動を壊さない。

- **配色 = catppuccin（mocha）**: `ui.lua` の先頭で `setup` → `colorscheme catppuccin`
  を適用する（lualine `theme="auto"` が追従できるよう lualine より前）。`vim.pack.add` の
  `name` は repo 名 `nvim` を避けて `catppuccin` を明示。flavour を変えれば
  mocha/macchiato/frappe/latte を切り替えられる。将来 tmux にテーマを入れる回で公式
  `catppuccin/tmux` と揃えられる点も選定理由（tmux 自体は別パッケージのスコープ）。
- **statusline = lualine**: `theme="auto"` で colorscheme に追従。モード表示は lualine に
  一本化し、組み込みの `showmode` は `ui.lua` で `false` にする。
- **インデントガイド = indent-blankline（v3 = `ibl`）**。
- **which-key**: キー押下途中に割当てをポップアップ表示。`<leader>p`=plugins /
  `<leader>h`=hunks / `<leader>f`=find のグループ名を登録（find の実キーマップは
  `finder.lua`）。既存マッピングの `desc` がそのまま説明になる。
- **git = gitsigns**: 変更を sign 列に表示。`on_attach` で git 管理下のバッファにのみ
  hunk ナビ `]c`/`[c`（diff モード時は組み込みへフォールバック）と `<leader>h` 系の
  hunk 操作（stage/reset/preview、buffer 単位、blame、表示切替）を `desc` 付きで付ける。
  既定では未追跡ファイルにはアタッチしない（`attach_to_untracked` 既定 false）。

## Finder（fuzzy finder）

ファイル検索・プロジェクト grep などの「探す」導線は `folke/snacks.nvim` の
**picker モジュール**で行う。設定は `finder.lua` に集約。純 Lua・**build 不要**・
外部バイナリ不要で、`vim.pack.add` は `version` を省略して default ブランチを使う。
require は pcall 保護で、未導入でも起動を壊さない。

- **picker のみ有効化**: `require("snacks").setup({ picker = { enabled = true } })`。
  dashboard / notifier / scroll / indent 等の他モジュールは setup に列挙せず、既定の
  無効のまま保つ。
- **外部バイナリ**: files/grep の実体は内部で `ripgrep`(rg) / `fd` を見つけて使う。
  必須ではない（無くても起動は壊れない）が、入れると大規模 repo で速い。
- **キーマップ（`<leader>f`=find）**: `desc` 付き・押下時に snacks を遅延参照。

  | キー | 機能 |
  |------|------|
  | `<leader>ff` | ファイルを検索（files） |
  | `<leader>fg` | プロジェクトを grep |
  | `<leader>fw` | カーソル下の語で grep |
  | `<leader>fb` | バッファを検索 |
  | `<leader>fr` | 最近開いたファイル |
  | `<leader>fh` | ヘルプタグ |
  | `<leader>fk` | キーマップ |
  | `<leader>fd` | 診断 |
  | `<leader>fs` | ドキュメントシンボル（LSP） |
  | `<leader>fl` | 直前の picker を再開（resume） |

  `<leader>f`=find のグループ名は `ui.lua` の which-key に登録（group 名は ui.lua、
  実キーマップは finder.lua という hunks と同じ分離）。LSP ナビ（`gd`/`grr` 等）の
  既定は置き換えていない。

## 展開

```sh
# リポジトリルートで
stow -n neovim   # ドライラン（衝突確認）
stow neovim      # ~/.config/nvim/ 配下にシンボリックリンクを作成
stow -D neovim   # 取り消し
```

## メモ

- `neovim/openspec/` はリポジトリルートの `.stowrc`（`--ignore=openspec`）により
  stow 対象外。ホームにはリンクされない。
- 動作確認環境: nvim 0.12.x。
