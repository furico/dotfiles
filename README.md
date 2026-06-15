# dotfiles

GNU Stow を使ってアプリごとの設定ファイルを管理するリポジトリ。

## ディレクトリ構造

アプリ名をトップレベルのディレクトリ（パッケージ）として、その中にホームディレクトリと同じパスで設定ファイルを配置する。

```
dotfiles/
├── vim/
│   └── .vimrc        # → ~/.vimrc
└── zsh/              # (例)
    └── .zshrc        # → ~/.zshrc
```

`stow <package>` を実行するとシンボリックリンクがホームディレクトリに作成される。

## Prerequisites

```sh
brew install stow
```

## セットアップ

```sh
git clone https://github.com/furihatah/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 管理したいパッケージを個別に stow する
stow vim
```

## 管理中のパッケージ

| パッケージ | 対象ファイル |
| --- | --- |
| `vim` | `~/.vimrc` |

## 新しいアプリを追加する

1. アプリ名のディレクトリを作成する
2. ホームディレクトリからの相対パスで設定ファイルを配置する
3. `stow <package>` でシンボリックリンクを作成する

```sh
mkdir -p ~/dotfiles/zsh
mv ~/.zshrc ~/dotfiles/zsh/.zshrc
cd ~/dotfiles
stow zsh
```

## パッケージを削除する

```sh
stow -D vim   # ~/.vimrc のシンボリックリンクを削除
```
