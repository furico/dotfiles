## Why

AI エージェント（Claude Code 等）+ tmux + Neovim をターミナル（ghostty / macOS）上で常用するワークフローを支える tmux 設定をゼロベースで整備する。Neovim 側は既にこの構成を前提とした実装が入っており（`autocmds.lua` の `FocusGained`/`checktime` による外部変更リロード、`FileChangedShellPost` 通知は「AI Agent 運用向け」と明記、`<C-hjkl>` のウィンドウ移動）、その「もう半分」である tmux 設定だけが未整備のため、Neovim 設定が前提とする契約を tmux 側で満たす必要がある。

## What Changes

- 新規 stow パッケージ `tmux` を追加し、tmux 設定を XDG 配置（`~/.config/tmux/tmux.conf`）に展開する。既存の tmux 設定は参照せずゼロベースで構築する。
- **契約設定**（Neovim 設定が前提とする、外せない正しさ）:
  - `focus-events on` — エージェントがディスク上のファイルを書き換えた後、エディタペインへ戻った瞬間に Neovim の `FocusGained`→`checktime` リロードを発火させる。これが無いと外部変更リロードのループが完成しない。
  - `escape-time 0`（または極小値）— `<Esc>` および端末モード離脱 `<Esc><Esc>` の遅延を解消する。
  - truecolor パススルー（`default-terminal "tmux-256color"` + `terminal-features` で `RGB` を `xterm-ghostty` 向けに付与）— Neovim の `termguicolors` の色化けを防ぐ。
  - `set-clipboard on`（OSC 52）— Neovim の `clipboard=unnamedplus` のヤンクを macOS クリップボードへ届ける。ghostty が OSC 52 を解するため SSH 越しでも機能する。
- **キー**:
  - prefix を `C-q` に変更（`C-b` を解除）。`C-a`（readline 行頭・nvim 数値インクリメント）や `C-Space`（IME 競合）を避けた選択。
  - ペイン移動を `prefix + hjkl`、リサイズを `prefix + HJKL` に割り当てる。シームレス移動（`C-hjkl`）は採らず、`C-hjkl` は nvim・シェル・AI エージェント（Claude Code の `C-j`=改行 など）に残す。
  - vi 風コピーモード、`mouse on`、設定リロードのバインドを追加する。
- **AI エージェント向けレイヤ**:
  - `monitor-silence` / `monitor-activity` + `visual-bell` — 長時間のエージェント実行が「完了した／入力待ちになった」ことをステータスで検知する。
  - 大きめの `history-limit` — エージェントの長い出力をさかのぼれるようにする。
  - `display-popup` のバインド — nvim+エージェントのレイアウトを崩さずスクラッチシェル / lazygit を出す。
  - レイアウトスクリプト — 「nvim ｜ エージェント ｜ シェル」配置をワンキーで起こす。
- **プラグイン**: TPM（tmux plugin manager）を導入するが、本 change で入れる追加プラグインは無い（将来テーマ等を入れる足場として残す）。シームレス移動（`vim-tmux-navigator`）・テーマ・`tmux-yank`・永続化はいずれも見送り（理由は下記および design 参照）。
- スコープに**含めない**もの:
  - シームレス移動（`vim-tmux-navigator`）。`C-hjkl` が AI エージェント（Claude Code の `C-j`=改行）・シェルの readline・nvim 挿入モードと衝突するため不採用とし、ペイン移動は `prefix + hjkl` で行う。これに伴い Neovim 側の変更は不要（本 change では nvim を触らない）。
  - セッション永続化（`tmux-resurrect` / `tmux-continuum`）。AI エージェントはプロセス状態まで復元できずレイアウト復元の価値が限定的なため見送る。
  - `stty -ixon`（`C-q`/`C-s` のフロー制御解放）。シェル側の設定のため `zsh` パッケージで別途扱う。

## Capabilities

### New Capabilities
- `tmux-core`: stow パッケージとしての XDG 配置、prefix（`C-q`）と基本キーバインド、契約設定（`focus-events`・`escape-time`・truecolor パススルー・`set-clipboard`）、vi コピーモード・mouse・リロード。
- `tmux-plugins`: TPM の導入と管理規約、当面見送るプラグイン（シームレス移動・テーマ・yank・永続化）の方針。
- `tmux-agent-workflow`: AI エージェント運用向けの挙動（`monitor-silence`/`activity` + `visual-bell`、`history-limit`、`display-popup`、レイアウトスクリプト）。

### Modified Capabilities
<!-- なし（Neovim パッケージの既存要件・ファイルは変更しない。ペイン移動を prefix + hjkl にしたため nvim 側の変更は不要で、neovim-keymaps の要件にも手を入れない） -->

## Impact

- 新規パッケージ: `tmux/.config/tmux/tmux.conf`（+ 必要に応じてレイアウトスクリプト）。`tmux/openspec/` はリポジトリルートの `.stowrc`（`--ignore=openspec`）により stow 対象外。
- 新規 README: `tmux/README.md`（neovim パッケージに倣う）。
- 依存: TPM をクローンする手順が必要。`~/.config/tmux` は stow でリポジトリへ symlink されるため、プラグインは stow 管理の外（`~/.local/share/tmux/plugins/`）に置き、`tmux.conf` の `TMUX_PLUGIN_MANAGER_PATH` で指す。`prefix + I` でプラグイン取得。
- 環境前提: macOS / ghostty（`TERM=xterm-ghostty`、OSC 52 対応）。
- 他パッケージへの影響: Neovim パッケージの要件・ファイルは変更しない。`C-q` のフロー制御解放は `zsh` パッケージ側の別タスクに委ねる（本 change 単体でも tmux 内では `C-q` を prefix として奪うため動作する）。
- ペイン移動は `prefix + hjkl` で完結し、Neovim 側の追加作業や端末（ghostty）依存は不要。
