#!/usr/bin/env bash
# project-layout — 「Neovim ｜ AI エージェント ｜ シェル」の作業レイアウトを起こす。
#
# 使い方:
#   project-layout [ディレクトリ]   # 省略時はカレントディレクトリ
#
# 冪等。対象ディレクトリ名のセッションが既にあれば、作らずにアタッチして前回の続きに戻る
# （tmux の detach/reattach による永続性を活かす）。
#
# レイアウト:
#   ┌────────────┬────────────┐
#   │            │  agent     │   左 : nvim
#   │  nvim      ├────────────┤   右上: AI エージェント（空で開く。起動は手動）
#   │            │  shell     │   右下: シェル
#   └────────────┴────────────┘
#
# agent ペインは意図的に空のシェルで開く。起動コマンドやオプションの変化で壊れないよう、
# エージェントの起動はユーザーが手で行う前提とする。

set -euo pipefail

dir="${1:-$PWD}"
dir="$(cd "$dir" && pwd)"                       # 絶対パス化
session="$(basename "$dir" | tr -c 'A-Za-z0-9_' '_')"  # セッション名に使えない文字を _ に

# 既存セッションがあればアタッチして終了（冪等）。
if tmux has-session -t "=$session" 2>/dev/null; then
  if [ -n "${TMUX:-}" ]; then
    exec tmux switch-client -t "=$session"
  else
    exec tmux attach-session -t "=$session"
  fi
fi

# 左ペイン: nvim。
tmux new-session -d -s "$session" -c "$dir"
tmux send-keys -t "$session" 'nvim .' Enter

# 右ペイン（agent）を作り、その下にシェルを足す。
tmux split-window -h -t "$session" -c "$dir"    # 右上: agent（空のシェル）
tmux split-window -v -t "$session" -c "$dir"    # 右下: shell

# nvim ペインへフォーカスを戻し、幅を広めに取る。
tmux select-pane -t "$session".1
tmux resize-pane -t "$session".1 -x 55%

# アタッチ（tmux 内からでも外からでも動くように分岐）。
if [ -n "${TMUX:-}" ]; then
  exec tmux switch-client -t "=$session"
else
  exec tmux attach-session -t "=$session"
fi
