## MODIFIED Requirements

### Requirement: 見送るプラグインの方針
本構成では `catppuccin/tmux` のみを追加プラグインとして採用する SHALL。以下はいずれも入れない: シームレス移動（`vim-tmux-navigator`）、永続化（`tmux-resurrect`/`tmux-continuum`）、`tmux-yank`、システム情報（`tmux-cpu`/`tmux-battery`）。理由を README もしくは設定コメントに残す。

#### Scenario: シームレス移動プラグインを含めない
- **WHEN** `tmux.conf` のプラグイン宣言を確認する
- **THEN** `vim-tmux-navigator` は含まれず、ペイン移動は `prefix + hjkl`（tmux-core）で行う。`C-hjkl` は nvim/シェル/AI エージェントに残す

#### Scenario: 永続化プラグインを含めない
- **WHEN** `tmux.conf` のプラグイン宣言を確認する
- **THEN** `tmux-resurrect`/`tmux-continuum` は含まれない

#### Scenario: yank とシステム情報プラグインを含めない
- **WHEN** `tmux.conf` のプラグイン宣言を確認する
- **THEN** `tmux-yank` は含まれず、クリップボードは `set-clipboard on`（OSC 52）で代替されている。`tmux-cpu`/`tmux-battery` も含まれず、ステータスバーは catppuccin の組み込みモジュールで構成される

#### Scenario: catppuccin/tmux は採用される
- **WHEN** `tmux.conf` のプラグイン宣言を確認する
- **THEN** `catppuccin/tmux` が宣言されており、`tmux-plugins/tpm` の次に記載されている
