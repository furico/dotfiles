# tmux

tmux の設定。GNU Stow で XDG Base Directory 配置（`~/.config/tmux/`）に展開する。
AI エージェント（Claude Code 等）+ tmux + Neovim を ghostty（macOS）上で常用する想定。

## 構成

```
tmux/
└── .config/tmux/
    ├── tmux.conf              本体。契約設定・キー・プラグイン・エージェント層
    └── scripts/
        └── project-layout.sh  「nvim ｜ agent ｜ shell」レイアウトを起こす
```

`tmux.conf` は Neovim 設定（`~/.config/nvim/`）と対になっている。Neovim 側は外部変更の
自動リロードやウィンドウ移動など、この三者構成を前提に実装されており、`tmux.conf` は
その前提を満たす「契約設定」を担う。

### 契約設定（Neovim が前提とする正しさ）

| 設定 | 目的 |
|------|------|
| `focus-events on` | 別ペインのエージェント編集後、nvim 復帰時に `FocusGained`→`checktime` で再読み込み |
| `escape-time 0` | `<Esc>` / 端末モード離脱 `<Esc><Esc>` の遅延を解消 |
| `terminal-features ...:RGB:usstyle` | nvim の `termguicolors`（truecolor）と下線スタイルを色化けなく通す |
| `set-clipboard on` | nvim の `clipboard=unnamedplus` のヤンクを OSC 52 でクリップボードへ |

## 主なキーバインド

prefix は **`C-q`**（既定の `C-b` は解除）。

| キー | 動作 |
|------|------|
| `prefix` + `r` | 設定リロード |
| `prefix` + `\|` / `-` | ペインを左右 / 上下に分割（現在ディレクトリを引き継ぐ） |
| `prefix` + `h/j/k/l` | ペイン移動 |
| `prefix` + `H/J/K/L` | ペインのリサイズ |
| `prefix` + `g` | スクラッチシェルのポップアップ |
| `prefix` + `C-g` | lazygit のポップアップ（インストール時） |
| `prefix` + `M` | 現在ウィンドウの無音監視トグル（エージェント完了検知） |
| コピーモード `v` / `y` | 選択開始 / ヤンク（クリップボードへ） |

## 展開

```sh
# 1) TPM（tmux plugin manager）をクローン
#    ~/.config/tmux は stow でリポジトリへ symlink されるため、プラグインは
#    stow 管理の外（XDG データ領域）に置く。tmux.conf の TMUX_PLUGIN_MANAGER_PATH と対。
git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm

# 2) リポジトリルートでシンボリックリンクを作成
stow -n tmux   # ドライラン（衝突確認）
stow tmux      # ~/.config/tmux/ 配下にリンクを作成
stow -D tmux   # 取り消し

# 3) tmux を起動し、prefix + I でプラグインを取得
tmux
# tmux 内で prefix + I（= C-q → Shift+i）を押すと catppuccin/tmux がインストールされる。
# インストール後、prefix + r でリロードするとテーマが適用される。
```

`project-layout.sh` をシェルから呼びやすくする場合は、zsh パッケージ側で
エイリアス/関数にするか PATH を通す（例: `alias pl='~/.config/tmux/scripts/project-layout.sh'`）。

## 採用プラグイン

- `tmux-plugins/tpm` … プラグインマネージャ。`prefix + I` でプラグインを取得する。
- `catppuccin/tmux` … catppuccin-mocha テーマ。Neovim のカラースキームと統一。

### 導入手順（新規マシン）

```sh
# 1) TPM をクローン（プラグインは stow 管理の外に置く）
git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm

# 2) tmux を起動し、prefix + I（= C-q → Shift+i）でプラグインを取得
#    catppuccin/tmux が ~/.local/share/tmux/plugins/catppuccin-tmux/ にインストールされる

# 3) prefix + r で設定をリロード（またはセッションを再起動）するとテーマが適用される
```

### 意図的に入れていないもの

- **シームレス移動（`vim-tmux-navigator`）** … `C-hjkl` を全ペインで横取りし、AI エージェント
  （Claude Code の `C-j`=改行）・シェルの readline・nvim 挿入モードの Ctrl を奪うため不採用。
  ペイン移動は `prefix + hjkl` で行う。シームレスが欲しくなった場合は Alt+hjkl 方式
  （ghostty の `macos-option-as-alt` が前提）へ切り替え可能。
- **tmux-yank** … `set-clipboard on`（OSC 52）で代替可能。マウスドラッグコピーの体感次第で後日判断。
- **tmux-resurrect / continuum**（セッション永続化）… AI エージェントはプロセス状態まで
  復元できず、レイアウト復元の価値が限定的なため見送り。
- **tmux-cpu / tmux-battery**（システム情報）… ステータスバーはシンプルに保つ。必要なら独立した変更で追加する。

## 次のタスク

- **`C-q` のフロー制御解放**は `zsh` パッケージ側で `stty -ixon` を入れる別タスク
  （tmux 内では tmux が `C-q` を奪うため、本設定単体でも動作する）。

## メモ

- `tmux/openspec/` はリポジトリルートの `.stowrc`（`--ignore=openspec`）により stow 対象外。
- ghostty は tmux 制御モード（`-CC`）非対応のため、tmux は通常モードで動かし、
  ウィンドウ/ペイン管理は tmux 側に集約する。
- 動作確認環境: tmux 3.6 / macOS / ghostty（`TERM=xterm-ghostty`）。
- ghostty 側で OSC 52 書き込みがブロックされる場合は ghostty の `clipboard-write` を許可に設定する。
