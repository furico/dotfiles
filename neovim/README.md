# neovim

Neovim の設定。GNU Stow で XDG Base Directory 配置（`~/.config/nvim/`）に展開する。

## 構成

```
neovim/
└── .config/nvim/
    ├── init.lua                 薄いローダ。require("config.options") のみ
    └── lua/config/
        └── options.lua          基本オプション + leader
```

`init.lua` はロード順を決めるだけの薄い層。将来 `lua/config/keymaps.lua` や
`lua/config/autocmds.lua`、プラグイン管理（lazy.nvim 等）を追加する際は
`require` 行を足すだけで拡張できる。

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
