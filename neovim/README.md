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
        └── plugins.lua          vim.pack によるプラグイン管理
```

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
