# 設定方法

macでのセットアップ方法。

## Homebrew

homebrewをインストールする。

- https://brew.sh/index_ja.html

## vim

clipboardオプションを有効にするため、brewでvimを入れる。

```
$ brew install vim --with-override-system-vi
```

もしくはMacVimを入れる。

## clone & setup

このリポジトリをcloneして `setup.sh` を実行する。

```
# サブモジュールも合わせてclone
$ git clone --recursive https://github.com/furico/dotfiles.git
$ ./setup.sh
```
