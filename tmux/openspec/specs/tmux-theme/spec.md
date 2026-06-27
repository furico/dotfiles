# tmux-theme Specification

## Purpose

tmux の外観（ステータスバー・ペイン枠・ウィンドウタブ）を catppuccin テーマで統一し、Neovim との視覚的一体感を保証する。

## Requirements

### Requirement: catppuccin-mocha テーマの適用
tmux は `catppuccin/tmux` プラグイン（TPM 管理）をフレーバー `mocha` で適用し、ステータスバー・ペイン枠・ウィンドウタブを catppuccin の配色で統一する SHALL。

#### Scenario: テーマが読み込まれる
- **WHEN** TPM で `catppuccin/tmux` をインストール済みの状態で tmux を起動する
- **THEN** ステータスバー・ペイン枠が catppuccin-mocha の配色で表示される

#### Scenario: フレーバーが mocha である
- **WHEN** `tmux.conf` の `@catppuccin_flavor` 設定を確認する
- **THEN** 値は `mocha` であり、Neovim の catppuccin-mocha と同じフレーバーが使われている

### Requirement: ステータスバーの最低限表示
tmux のステータスバーには最低限の情報（セッション名・現在ウィンドウ名・ホスト名・時刻）を表示する SHALL。追加プラグイン（cpu・battery 等）は使わない。

#### Scenario: ステータスバーにセッション名と時刻が表示される
- **WHEN** tmux セッション内でステータスバーを確認する
- **THEN** セッション名、現在アクティブなウィンドウ名、ホスト名、現在時刻が表示される

#### Scenario: システム情報プラグインを使わない
- **WHEN** `tmux.conf` のプラグイン宣言を確認する
- **THEN** `tmux-plugins/tmux-cpu` / `tmux-plugins/tmux-battery` は含まれず、catppuccin の組み込みモジュールのみで構成される

### Requirement: 新規マシンでのテーマ取得手順
`catppuccin/tmux` は TPM 経由でインストールでき、README に手順が記載されている SHALL。

#### Scenario: prefix + I でテーマプラグインを取得できる
- **WHEN** TPM をクローン済みの状態で tmux 内にて `prefix + I` を実行する
- **THEN** `catppuccin/tmux` が `~/.local/share/tmux/plugins/` にインストールされ、次回 tmux 起動時からテーマが適用される
