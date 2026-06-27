## Context

`tmux.conf` には TPM（`~/.local/share/tmux/plugins/`）の足場がすでに存在する。追加プラグインの宣言と `prefix + I` によるインストールで即時導入できる状態にある。Neovim は catppuccin-mocha を採用済みであり、tmux 側もフレーバーを揃えることで三者構成の統一感を実現する。

## Goals / Non-Goals

**Goals:**
- `catppuccin/tmux` を TPM で管理し、フレーバーを `mocha` に設定する
- ステータスバーに最低限の情報（セッション名・現在ウィンドウ名・ホスト名・時刻）を表示する
- ペイン枠の色も catppuccin テーマで統一する

**Non-Goals:**
- `tmux-plugins/tmux-cpu` / `tmux-battery` などのシステム情報プラグインは入れない
- カスタムスクリプトや外部ファイルは追加しない（`tmux.conf` のみ変更）
- ステータスバーに Neovim の LSP 状態・git ブランチ等の詳細情報は表示しない

## Decisions

### catppuccin/tmux v2 系を使用する
catppuccin/tmux は v1 と v2 で設定 API が大きく異なる。v2（`@catppuccin_flavor` キーを使う系）を採用する。理由: v1 は `@catppuccin_status_*` 形式で非推奨になっており、v2 がメンテナンスの主軸。

### ステータスバーは catppuccin の組み込みモジュールのみで構成する
`status-left` / `status-right` を catppuccin の `#{E:@catppuccin_status_*}` モジュールで組む。カスタムシェルスクリプトは使わない。理由: シンプルさを保ち、依存なしで動く構成にする。

### ウィンドウスタイルは "rounded"（デフォルト）を使う
catppuccin/tmux のウィンドウタブスタイルを `rounded` にする。理由: ghostty と組み合わせたときの視認性が高く、Neovim の UI（rounded borders）とも統一感がある。

## Risks / Trade-offs

- **[Risk] catppuccin/tmux の API が将来変わる** → TPM は特定コミットに pin できる（`set -g @plugin 'catppuccin/tmux#v2.x.x'`）が、初期導入は HEAD で行い、安定性が確認できたら pin を検討する。
- **[Risk] stow でリンクされた `~/.config/tmux/` にプラグインが混入しない** → `TMUX_PLUGIN_MANAGER_PATH` を `~/.local/share/tmux/plugins/` に設定済みのため問題なし。
- **[Trade-off] tmux-cpu/battery を入れないためシステム情報は表示されない** → ステータスバーのシンプルさを優先。必要になったら独立した change で追加する。
