## 1. プラグイン宣言と設定（tmux.conf）

- [x] 1.1 `tmux.conf` のプラグインセクションに `set -g @plugin 'catppuccin/tmux'` を追加する
- [x] 1.2 `@catppuccin_flavor 'mocha'` を設定する
- [x] 1.3 ウィンドウスタイルを `@catppuccin_window_status_style "rounded"` に設定する
- [x] 1.4 `status-left` を catppuccin のセッション名モジュール（`#{E:@catppuccin_status_session}`）で設定する
- [x] 1.5 `status-right` をホスト名・時刻の catppuccin モジュールで設定する（`host` + `date_time`）
- [x] 1.6 「テーマは Neovim のカラースキームが確定後に揃える」という旧コメントを削除し、catppuccin 採用理由のコメントに差し替える

## 2. プラグインのインストール確認

- [x] 2.1 `~/.local/share/tmux/plugins/tpm` がクローン済みであることを確認する（未導入なら README 手順に従いクローン）
- [x] 2.2 tmux 内で `prefix + I` を実行し `catppuccin/tmux` が `~/.local/share/tmux/plugins/catppuccin-tmux/` にインストールされることを確認する
- [x] 2.3 tmux を再起動（または `prefix + r` でリロード）し、ステータスバー・ペイン枠が catppuccin-mocha の配色で表示されることを目視確認する

## 3. README の更新

- [x] 3.1 「採用プラグイン」セクションに `catppuccin/tmux` を追記し、`prefix + I` でのインストール手順を明記する
- [x] 3.2 「意図的に入れていないもの」の配色テーマ項目を削除し（catppuccin/tmux を採用したため）、新たに不採用の理由（cpu/battery 等は追加しない）を残す

## 4. 仕上げ

- [x] 4.1 `stow -n tmux` でドライランし、catppuccin 設定ファイルが stow 管理対象外（`~/.local/share/`）に収まることを確認する
- [x] 4.2 Neovim を tmux 内で開き、catppuccin-mocha テーマの色が Neovim・tmux ステータスバーで統一されていることを確認する
