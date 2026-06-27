## ADDED Requirements

### Requirement: TPM によるプラグイン管理
tmux は TPM（tmux plugin manager）でプラグインを管理する SHALL。`tmux.conf` にプラグイン宣言と TPM の初期化行を含め、TPM のインストール手順を README に記載する SHALL。

#### Scenario: プラグインを取得できる
- **WHEN** TPM をクローン済みの状態で `prefix + I` を実行する
- **THEN** `tmux.conf` で宣言したプラグインがインストールされ有効になる

#### Scenario: クリーンな環境での導入手順
- **WHEN** 新しいマシンで README の手順に従い TPM をクローンして tmux を起動する
- **THEN** プラグイン取得の前提（TPM の配置）が満たされ、`prefix + I` で導入が完了する

### Requirement: 見送るプラグインの方針
本 change では追加プラグインを導入しない SHALL（TPM は将来のための足場として残す）。以下はいずれも入れない: シームレス移動（`vim-tmux-navigator`）、永続化（`tmux-resurrect`/`tmux-continuum`）、配色テーマ、`tmux-yank`。理由を README もしくは設定コメントに残す。

#### Scenario: シームレス移動プラグインを含めない
- **WHEN** `tmux.conf` のプラグイン宣言を確認する
- **THEN** `vim-tmux-navigator` は含まれず、ペイン移動は `prefix + hjkl`（tmux-core）で行う。`C-hjkl` は nvim/シェル/AI エージェントに残す

#### Scenario: 永続化プラグインを含めない
- **WHEN** `tmux.conf` のプラグイン宣言を確認する
- **THEN** `tmux-resurrect`/`tmux-continuum` は含まれない

#### Scenario: テーマと yank を含めない
- **WHEN** `tmux.conf` のプラグイン宣言を確認する
- **THEN** 配色テーマプラグインと `tmux-yank` は含まれず、クリップボードは `set-clipboard on`（OSC 52）で代替されている
