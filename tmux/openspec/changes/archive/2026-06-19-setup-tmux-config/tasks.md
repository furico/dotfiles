## 1. パッケージの足場

- [x] 1.1 `tmux/.config/tmux/tmux.conf` を新規作成（空のスケルトン + セクション見出しコメント）
- [x] 1.2 `tmux/README.md` を作成（neovim パッケージに倣い、構成・stow 手順・TPM クローン手順・ghostty 前提を記載）
- [x] 1.3 `stow -n tmux` のドライランで衝突がないこと、`openspec/` がリンク対象外であることを確認

## 2. 契約設定（tmux-core）

- [x] 2.1 `focus-events on` を設定し、なぜ必要か（nvim の FocusGained→checktime を支える）をコメントで明記
- [x] 2.2 `escape-time` を 0（または極小値）に設定
- [x] 2.3 `default-terminal "tmux-256color"` + `terminal-features` で `RGB` を `xterm-ghostty` 向けに付与（truecolor）
- [x] 2.4 `set-clipboard on`（OSC 52）を設定
- [x] 2.5 nvim を tmux 内（ghostty）で開き、truecolor 表示・ヤンク→macOS クリップボード・別ペイン編集後のフォーカス復帰リロードを確認

## 3. キーと操作（tmux-core）

- [x] 3.1 prefix を `C-q` に変更し `C-b` を解除
- [x] 3.2 設定リロードのバインドを追加
- [x] 3.3 コピーモードを vi キーバインドに設定（`v` 選択・`y` ヤンク→システムクリップボード）
- [x] 3.4 `mouse on` を設定
- [x] 3.5 ペイン分割・移動・リサイズ等の基本バインドを整備

## 4. プラグイン（tmux-plugins）

- [x] 4.1 TPM のクローン手順を README に記載（`~/.config/tmux/plugins/tpm`）
- [x] 4.2 `tmux.conf` に TPM のプラグイン宣言と初期化行（`run '.../tpm'`）を追加
- [x] 4.3 シームレス移動（`vim-tmux-navigator`）は不採用とし、ペイン移動は `prefix + hjkl`（tmux-core 側）にする。不採用理由（`C-hjkl` が AI エージェント/シェル/nvim と衝突）をコメント・README に明記
- [x] 4.4 見送るプラグイン（resurrect/continuum・テーマ・yank）の方針をコメント/README に残す
- [x] 4.5 TPM の仕組み（`prefix + I`）が有効なこと、`prefix + hjkl` のペイン移動・`prefix + HJKL` のリサイズが効くこと、`C-hjkl` がアプリ側に残ることを確認

## 5. AI エージェント向けレイヤ（tmux-agent-workflow）

- [x] 5.1 大きめの `history-limit` を設定
- [x] 5.2 `monitor-silence`/`monitor-activity` + `visual-bell` を設定し、ステータスラインで背景ペインの状態が見えるようにする（無音閾値の意図をコメント）
- [x] 5.3 `display-popup` を開くバインドを追加（スクラッチシェル / lazygit 用）
- [x] 5.4 「nvim ｜ エージェント ｜ シェル」レイアウトを起こすスクリプトまたはバインドを追加
- [x] 5.5 エージェント実行→無音検知の通知、ポップアップ開閉、レイアウト起動を動作確認

## 6. 仕上げ

- [x] 6.1 `stow tmux` で本適用し、全体（契約設定・キー・プラグイン・エージェントレイヤ）を通しで動作確認
- [x] 6.2 README に見送ったプラグインの方針（シームレス移動を含む）と次タスク（zsh の `stty -ixon`）への導線を明記
