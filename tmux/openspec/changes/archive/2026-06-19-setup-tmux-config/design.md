## Context

AI エージェント + tmux + Neovim を ghostty（macOS）上で常用する構成。Neovim 設定（`neovim/.config/nvim/`）は既にこの三者構成を前提に実装されている:

- `autocmds.lua` … `FocusGained`/`TermClose`/`TermLeave` で `checktime`、`FileChangedShellPost` で通知（コメントに「AI Agent 運用向け」「focus-events 設定は tmux パッケージ回で扱う」と明記）。
- `keymaps.lua` … `<C-hjkl>` をウィンドウ移動に割当、`<Esc><Esc>` で端末モード離脱、`<Esc>` で `nohlsearch`。
- `options.lua` … `termguicolors`、`clipboard=unnamedplus`。

つまり tmux 側は自由なゼロ設計ではなく、Neovim 設定が前提とする「契約」を満たす必要がある。リポジトリは GNU Stow 管理で、各トップレベルディレクトリが stow パッケージ。`.stowrc` の `--ignore=openspec` と `.*\.local\.example` が除外対象。Neovim パッケージは XDG 配置・薄いローダ・高コメント密度・「まず素で、必要になったら足す」という方針を確立しており、本パッケージもそれに倣う。

決定済みの方針: prefix=`C-q`、プラグイン管理=TPM（現状 追加プラグインなし）、ペイン移動=`prefix + hjkl`（シームレス移動は apply 中の検証で不採用に変更）、永続化=なし、Neovim 側の変更=不要。

## Goals / Non-Goals

**Goals:**
- Neovim 設定が前提とする契約（focus-events / escape-time / truecolor / clipboard）を tmux 側で満たす。
- AI エージェント運用に効く挙動（完了検知・スクロールバック・ポップアップ・作業レイアウト）を備える。
- Neovim パッケージと一貫した配置・スタイル（XDG・stow・高コメント密度）。
- TPM を導入しつつ、プラグインは最小限から始める。

**Non-Goals:**
- Neovim 側の変更 — 不要（ペイン移動を `prefix + hjkl` にしたため nvim を触らない）。
- セッション永続化（resurrect/continuum）。
- 配色テーマの確定（Neovim のカラースキーム未定のため保留）。
- `stty -ixon` によるフロー制御解放（`zsh` パッケージの別タスク）。

## Decisions

### prefix = `C-q`
- **理由**: `C-a`（readline 行頭・nvim 数値インクリメント）、`C-Space`（日本語 IME のトグルと競合しやすい）、`C-b`（押しづらく nvim のページ戻しを奪う）を避けた結果。`C-q` は衝突が少なく、ghostty も macOS では `Cmd-Q` 終了のため `C-q` を奪わない。
- **代替案**: `C-a`（screen 互換だがシェル操作を犠牲）/ `C-Space`（IME 競合）/ `C-b` 既定（押下性で不採用）。
- **トレードオフ**: `C-q` は XON/XOFF フロー制御に使われるため `stty -ixon` が望ましい。ただし tmux 内では tmux が `C-q` を先に奪うので本 change 単体でも動作する。nvim の `C-q`（`C-v` の別名・矩形ビジュアル）は失うが `C-v` が残るため実害なし。フロー制御解放は zsh 側の別タスク。

### ペイン移動は prefix + hjkl（シームレス移動は不採用）
- **背景**: 当初は `vim-tmux-navigator` による `C-hjkl` シームレス移動を採る方針だったが、apply 中の実機検証で問題が判明した。navigator は「現在ペインが nvim か」だけで分岐し、**nvim 以外の全ペインで `C-hjkl` を横取り**する。判定正規表現は `node`/`claude` にマッチしないため、AI エージェント（**Claude Code の `C-j`=改行**）・シェルの readline・nvim 挿入モードの Ctrl キーが奪われる。AI エージェントが主役の本構成では受け入れられない。
- **決定**: ペイン移動は `prefix + hjkl`（リサイズは `prefix + HJKL`）にし、`C-hjkl` は一切奪わずアプリに残す。これにより Neovim 側の変更も ghostty 依存も不要になる（この決定は当初の「シームレス移動」「nvim 側は別タスク」を**置き換える**）。
- **代替案**: ① C-hjkl シームレス（navigator）… Claude Code の改行等 Ctrl を奪うため却下 / ② Alt+hjkl シームレス（navigator のキー再割当 `@vim_navigator_mapping_*`）… Ctrl は守れるが ghostty の `macos-option-as-alt` 依存が増える。ユーザー判断で簡潔さを優先し prefix 方式を採用。
- **影響**: `vim-tmux-navigator`（tmux 側プラグイン）は不要となり削除。`keymaps.lua`（nvim の `<C-hjkl>` ウィンドウ移動）は本 change で触らず、衝突も生じない。

### TPM 採用・現状は追加プラグインなし
- **理由**: ユーザー方針で TPM 採用。ただし上記でシームレス移動を取りやめた結果、本 change で導入する追加プラグインは無くなった。TPM は将来テーマ等を入れるための足場として残す（`prefix + I` の仕組みは有効）。
- **見送り**: シームレス移動（`vim-tmux-navigator`、上記理由）、テーマ（nvim カラースキーム未定のため確定後に揃える）、`tmux-yank`（`set-clipboard on`+OSC 52 で代替、マウスドラッグコピーが不便なら後日追加）、resurrect/continuum（エージェントはプロセス復元不可で価値限定）。

### 契約設定は明示的に書く
- **理由**: `tmux-sensible` 等に暗黙依存せず、`focus-events on`・`escape-time 0`・`default-terminal "tmux-256color"`+`terminal-features` の `RGB`・`set-clipboard on` を `tmux.conf` に明示し、コメントで「なぜ必要か（どの nvim 挙動を支えるか）」を残す。Neovim パッケージのコメント方針に一致。

### TPM/プラグインは stow 管理の外（XDG データ領域）に置く
- **理由**: stow は `~/.config/tmux` をディレクトリごとリポジトリへ symlink する（folding）。既定の `~/.config/tmux/plugins/` にクローンすると、ダウンロードされた各プラグインの git リポジトリがリポジトリ作業ツリー内に入り込み `git status` を汚す。プラグインは「生成物」でソース管理対象外のため、`~/.local/share/tmux/plugins/` に置き、`tmux.conf` で `set-environment -g TMUX_PLUGIN_MANAGER_PATH` と `run` のパスを合わせる。
- **代替案**: ① リポジトリ内に置き `.gitignore` で除外（設定変更は不要だが生成物がリポジトリ dir 内に同居する）/ ② stow を `--no-folding` で個別ファイルリンクにし `plugins/` を実ディレクトリにする（stow 運用全体に影響するため見送り）。apply 中の実機検証で folding 由来の混入が判明したため本決定を採用。

### エージェント完了検知は monitor-silence/activity + visual-bell
- **理由**: 長時間エージェントの「終わった／入力待ち」を背景ペインで気づくのが運用上の主目的。`monitor-silence`（無音=処理完了の目安）と `monitor-activity` を使い分け、通知は `visual-bell` で画面表示にする（音は出さない）。
- **トレードオフ**: 無音閾値は誤検知し得る（出力が散発的なエージェントだと早すぎ/遅すぎ）。閾値は調整前提でコメントに既定値の意図を残す。

## Risks / Trade-offs

- **[シームレス移動を諦めた]** → ペイン移動に毎回 `prefix` を挟む必要がある。ただし `C-hjkl` を AI エージェント・シェル・nvim に残せる利点が上回ると判断（apply 中の実機検証で Claude Code の `C-j`=改行 が奪われる問題が決め手）。シームレスが必要になれば Alt+hjkl 案（ghostty `macos-option-as-alt` 前提）へ再変更可能。
- **[`C-q` でフロー制御に引っかかる]** → tmux 内では tmux が奪うため動作。シェルでの解放は zsh パッケージの別タスクに切り出し済み。
- **[truecolor/clipboard が端末依存]** → ghostty（`xterm-ghostty`・OSC 52）前提を明記。`terminal-features` は実行端末に合わせて付与し、必要なら検証手順を README に残す。
- **[TPM 未クローンだと初回プラグインが入らない]** → README に TPM クローン手順と `prefix + I` を明記。設定は TPM 不在でも tmux 自体は起動できるよう初期化行を末尾に置く。
- **[ghostty は tmux 制御モード（`-CC`）非対応]** → tmux は通常モードで動かす前提。ghostty 側の splits/tabs ではなく tmux にセッション/ペイン管理を寄せる。

## Migration Plan

- 新規パッケージのため後方互換の懸念は小さい。手順: ① `tmux/.config/tmux/tmux.conf`（+ レイアウトスクリプト）と `tmux/README.md` を作成 → ② TPM をクローン → ③ `stow tmux` → ④ tmux 起動・`prefix + I` でプラグイン取得 → ⑤ 契約設定（focus-events/truecolor/clipboard）を nvim と組み合わせて動作確認。
- ロールバック: `stow -D tmux` でリンク削除。既存設定はゼロベース新規のため復元対象なし。

## Open Questions

- 配色テーマの系統（tokyonight / catppuccin など）— Neovim のカラースキーム確定後に揃える。
- `monitor-silence` の無音閾値の既定値 — 実運用で調整。
- `tmux-yank` の要否 — マウスドラッグコピーの体感次第で後日判断。
