#!/bin/bash

#
# ホームディレクトリにシンボリックリンクを作成する
#

# ファイル
ln -sf $(pwd)/.bashrc ${HOME}/.bashrc
ln -sf $(pwd)/.vimrc ${HOME}/.vimrc

# ディレクトリ
# if [ ! -e ${HOME}/.vim ]; then
#   ln -sf $(pwd)/vim ${HOME}/.vim
# fi
# if [ ! -e ${HOME}/settings ]; then
#   ln -sf $(pwd)/settings ${HOME}/settings
# fi
# ln -sf $(pwd)/bin ${HOME}
