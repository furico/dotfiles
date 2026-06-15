## 1. ディレクトリ構成の作成

- [x] 1.1 `neovim/.config/nvim/` と `neovim/.config/nvim/lua/config/` ディレクトリを作成する
- [x] 1.2 `neovim/README.md` を作成し、XDG 配置（`~/.config/nvim/`）と stow 展開方法、openspec が stow 対象外である旨を記す

## 2. 薄い init.lua ローダ

- [x] 2.1 `neovim/.config/nvim/init.lua` を作成し、`require("config.options")` のみを記述する（将来 keymaps/autocmds を追加できる構成にする）

## 3. オプション本体

- [x] 3.1 `neovim/.config/nvim/lua/config/options.lua` を作成する
- [x] 3.2 leader を設定する（`vim.g.mapleader=" "`, `vim.g.maplocalleader="\\"`）
- [x] 3.3 表示系オプションを設定（number, relativenumber, cursorline, signcolumn="yes", scrolloff=10, termguicolors, wrap=false, showmode は既定のまま）
- [x] 3.4 `list` を有効化し、`vim.opt.listchars` を `{ tab, trail, nbsp }` で設定する
- [x] 3.5 インデント系を設定（expandtab, shiftwidth=2, tabstop=2, smartindent, shiftround, breakindent）
- [x] 3.6 検索系を設定（ignorecase, smartcase, inccommand="split"）
- [x] 3.7 編集・ファイル系を設定（undofile, undolevels=10000, confirm, mouse="a", clipboard="unnamedplus", autoread, updatetime=250, timeoutlen=300）
- [x] 3.8 分割系を設定（splitright, splitbelow）

## 4. 展開と検証

- [x] 4.1 リポジトリルートで `stow -n neovim` を実行し、衝突が無いことを確認する
- [x] 4.2 `stow neovim` で `~/.config/nvim/` 配下にシンボリックリンクが作成されることを確認する
- [x] 4.3 `nvim` を起動してエラーが出ないこと、主要オプション（行番号・truecolor・インデント幅）が反映されることを確認する
- [x] 4.4 leader が `" "`、localleader が `"\"` に設定されていることを確認する（`:echo mapleader` 等）
