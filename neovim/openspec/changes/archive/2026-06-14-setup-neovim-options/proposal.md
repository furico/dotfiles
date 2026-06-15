## Why

dotfiles リポジトリにはまだ Neovim 設定が存在しない。ゼロベースで Neovim を立ち上げるにあたり、まず土台となる基本オプション（表示・インデント・検索・編集挙動）を整える。将来の AI Agent + tmux + Neovim 運用やプラグイン導入の前提として、最初に「素の Neovim を快適に使える状態」を確定させておきたい。

## What Changes

- `neovim/` を新しい stow パッケージとして追加し、XDG 配置（`~/.config/nvim/`）で展開する。
- `init.lua` を「ロード順を決めるだけの薄いローダ」として作成し、`require("config.options")` のみを行う。
- `lua/config/options.lua` に基本オプション一式と leader キー設定を定義する。
- 書き方は `vim.o` を基本とし、テーブルが必要な箇所（`listchars`）のみ `vim.opt` を使う。
- 今回のスコープに**含めない**もの（将来の別 change で扱う）:
  - `autoread` を実効化する `checktime` autocmd
  - `showmode=false` / `statuscolumn` などステータスラインプラグイン依存の設定
  - keymap 全般
  - プラグイン管理（lazy.nvim 等）

## Capabilities

### New Capabilities
- `neovim-options`: Neovim の基本オプション設定と leader キー、およびそれらを読み込む薄い `init.lua` ローダ構成。stow で XDG 配置に展開される設定ファイル群を含む。

### Modified Capabilities
<!-- なし（新規パッケージのため既存 spec の要件変更はない） -->

## Impact

- 新規ファイル: `neovim/.config/nvim/init.lua`、`neovim/.config/nvim/lua/config/options.lua`、`neovim/README.md`。
- stow パッケージ `neovim` の追加。`stow neovim` で `~/.config/nvim/` 配下にシンボリックリンクが作成される。
- `neovim/openspec/` はリポジトリルートの `.stowrc`（`--ignore=openspec`）により stow 対象外（リンクされない）。
- 既存パッケージ（vim, zsh）への影響なし。
