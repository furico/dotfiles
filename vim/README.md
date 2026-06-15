# vim

Vim の設定ファイル。GNU Stow で `~/.vimrc` にシンボリックリンクを作成する。

## セットアップ

### 1. シンボリックリンクの作成

```sh
cd ~/dotfiles && stow vim
```

### 2. minpac のインストール

プラグインマネージャ（minpac）本体は手動でクローンする：

```sh
git clone https://github.com/k-takata/minpac.git \
  ~/.vim/pack/minpac/opt/minpac
```

### 3. プラグインのインストール

Vim を起動して以下を実行：

```vim
:PackUpdate
```

### 4. ~/.vimrc.local（任意）

マシン固有の設定（カラースキームなど）は `~/.vimrc.local` に記述する。
ファイルがない場合は `zenburn` → `desert` の順でフォールバックする。

## 依存

- `git` — vim-fugitive・vim-gitgutter が必要とする
