#!/bin/bash
# ホームディレクトリにシンボリックリンクを作成する

cd $(dirname $0)
base_dir=$(pwd)

# vim
ln -sf ${base_dir}/vim/vimrc ${HOME}/.vimrc
# tmux
ln -sf ${base_dir}/tmux/tmux.conf ${HOME}/.tmux.conf
# bash-it
ls bash/bash_it/custom/*.bash \
| xargs -I{} basename {} \
| xargs -I{} ln -sf ${base_dir}/bash/bash_it/custom/{} ${HOME}/.bash_it/custom/{}
