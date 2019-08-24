#!/bin/bash
# ホームディレクトリにシンボリックリンクを作成する

cd $(dirname $0)
base_dir=$(pwd)

# vim
ln -sf ${base_dir}/vim/vimrc ${HOME}/.vimrc
ln -sf ${base_dir}/vim/bundle/ ${HOME}/.vim
# tmux
ln -sf ${base_dir}/tmux/tmux.conf ${HOME}/.tmux.conf
