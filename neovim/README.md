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
        └── treesitter.lua       nvim-treesitter（main）の設定
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
