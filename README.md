# 設定方法

macでのセットアップ方法。

## Homebrew

homebrewをインストールする。

- https://brew.sh/index_ja.html

## bash

brewでbashを最新化する。

```
$ brew install bash
$ echo '/usr/local/bin/bash' | sudo tee -a /etc/shells
$ chsh -s /usr/local/bin/bash
```

## vim

clipboardオプションを有効にするため、brewでvimを入れる。

```
$ brew install vim --with-override-system-vi
```

## 標準コマンド

macの標準コマンドをlinuxに合わせる。

```
$ brew install coreutils gnu-sed
```

`~/.bash_profile` に `PATH` を設定する。

* 後述の `bash-it` の設定よりも前に記述すること。
* そうしないと `ls` コマンドの色設定が上手く行われない。

```
# coreutils
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

# gnu-sed
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH"
```

## bash-it

`bash-it` を入れる

* https://github.com/Bash-it/bash-it

## 設定ファイルをコピー

このリポジトリをcloneして `setup.sh` を実行する。

* `bash-it` がインストールされていることを前提としているため、先に `bash-it` をインストールしておくこと。

## その他の設定

### export

必要に応じて `~/.bash_profile` に入れる。 `~/.bash_profile` 自体はgitで管理しない。

### その他スクリプト

必要に応じて `bash/bash_it` 配下にカスタムスクリプトを作成する。
