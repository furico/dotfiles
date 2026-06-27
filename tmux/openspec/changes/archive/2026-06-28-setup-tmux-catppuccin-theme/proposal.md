## Why

Neovim のカラースキームが catppuccin-mocha に確定したため、tmux の外観（ステータスバー・ペイン枠）も同じテーマで統一し、三者構成（Neovim ｜ エージェント ｜ シェル）の視覚的な一体感を得る。TPM の足場はすでに `tmux.conf` に存在しており、プラグインを追加するだけで導入できる状態にある。

## What Changes

- `tmux.conf` のプラグインセクションに `catppuccin/tmux` を追加し、フレーバーを `mocha` に設定する
- ステータスバーの表示内容（現在ウィンドウ名・ホスト名・時刻）を catppuccin テーマで構成する
- `tmux.conf` 内の「テーマは未定」コメントを削除し、採用理由コメントに置き換える
- `README.md` のプラグイン一覧に `catppuccin/tmux` を追記し、`prefix + I` での取得手順を明示する

## Capabilities

### New Capabilities

- `tmux-theme`: tmux の外観（ステータスバー・ペイン枠・ウィンドウタブ）を catppuccin-mocha で統一する能力

### Modified Capabilities

- `tmux-plugins`: TPM が管理する追加プラグインに `catppuccin/tmux` が加わるため、「現状 TPM が管理する追加プラグインは無い」という要件が変わる

## Impact

- 変更ファイル: `tmux/.config/tmux/tmux.conf`、`tmux/README.md`
- 新規依存: `catppuccin/tmux`（TPM 経由で `~/.local/share/tmux/plugins/catppuccin-tmux/` に配置）
- 追加プラグインなし（`tmux-cpu`・`tmux-battery` 等は不採用。シンプルさを保つ）
- `tmux-plugins/tpm` への依存は既存のまま
