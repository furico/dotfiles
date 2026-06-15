# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

GNU Stow でアプリごとの dotfile を管理するリポジトリ。トップレベルの各ディレクトリが stow パッケージに対応し、`stow <package>` でホームディレクトリにシンボリックリンクが作成される。

## よく使うコマンド

```sh
# パッケージのシンボリックリンクを作成
stow <package>

# シンボリックリンクを削除
stow -D <package>

# ドライラン（実際には何もしない）
stow -n <package>
```

## 除外設定

リポジトリルートの `.stowrc` に `--ignore=<正規表現>` を列挙したディレクトリ・ファイルはシンボリックリンク対象外になる（`.stowrc` はリポジトリルートで `stow` を実行したときに読み込まれる）。現在の除外対象:

- `openspec` … 各パッケージの OpenSpec 成果物
- `.*\.local\.example` … `*.local.example` などのサンプルファイル

`README.*` や `LICENSE.*`、`.git` などは GNU Stow の組み込みデフォルトで除外されるため `.stowrc` への記載は不要。

## 新しいパッケージを追加するとき

既存の設定ファイルをリポジトリに取り込む場合:

```sh
mkdir -p ~/dotfiles/<app>
mv ~/.<configfile> ~/dotfiles/<app>/.<configfile>
cd ~/dotfiles && stow <app>
```
