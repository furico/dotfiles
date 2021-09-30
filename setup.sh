#!/bin/bash
# ホームディレクトリにシンボリックリンクを作成する

cd $(dirname $0)
base_dir=$(pwd)

# vim
ln -sf ${base_dir}/vim/vimrc ${HOME}/.vimrc
ln -sf ${base_dir}/vim/pack/ ${HOME}/.vim
# tmux
ln -sf ${base_dir}/tmux/tmux.conf ${HOME}/.tmux.conf
ln -sf ${base_dir}/config/nvim/ ${HOME}/.config/
