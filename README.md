# for mac

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

PATH等も設定する。

```
# coreutils
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

# gnu-sed
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH"
```

## pecoの設定

- https://qiita.com/tmsanrinsha/items/72cebab6cd448704e366
