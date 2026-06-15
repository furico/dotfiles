## Context

dotfiles リポジトリは GNU Stow でアプリごとに設定を管理する。既存パッケージ（`vim`, `zsh`）はホーム直下配置（`vim/.vimrc` → `~/.vimrc`）だが、Neovim は XDG Base Directory に従い `~/.config/nvim/` に置くため、パッケージ内のパスが一段深くなる。

環境は nvim 0.12.3。参考にしたのは kickstart.nvim（最小・単一 init.lua・`vim.o` 中心）と LazyVim（分割構成・`vim.opt` 中心・フレームワーク依存）。今回はゼロベースで、両者の「良いとこ取り」を最小スコープで行う。将来は AI Agent + tmux + Neovim 運用、およびプラグイン導入を見据える。

## Goals / Non-Goals

**Goals:**
- 素の Neovim を快適に使える基本オプションを確定する。
- 将来 keymap / autocmd / plugin が増えても破綻しないディレクトリ構成（薄いローダ + `lua/config/`）を最初に用意する。
- stow で XDG 配置に展開でき、openspec 成果物はリンクされない構成にする。

**Non-Goals:**
- keymap、autocmd、プラグイン管理（lazy.nvim 等）の導入。
- ステータスライン等プラグインに依存するオプション（`showmode=false`, `statuscolumn`, `formatexpr` 等）。
- SSH / リモート経由でのクリップボード（OSC52）対応。今回はローカル運用前提。

## Decisions

### D1: 分割構成（薄い init.lua + lua/config/）を最初から採用

単一 init.lua（kickstart 流）でも今回の量なら動くが、宣言どおり将来 keymap / autocmd / plugin が確実に増える。増えてから割るより、最初から `init.lua` を `require("config.options")` だけの薄いローダにしておく方が移行コストが低い。lazy.nvim を挟む際も `require("config.lazy")` を一行足すだけで済む。

代替案: 単一 init.lua で始めて後で分割 → 却下（分割タイミングの判断と差分が無駄）。

### D2: `vim.o` 基本・`listchars` のみ `vim.opt`

`vim.o` はスカラ代入で素直。`listchars` のようなテーブル値は `vim.opt` の方が書きやすい。nvim 0.12 では `vim.o` でも十分機能するため、全面 `vim.opt`（LazyVim 流）にする必要はない。「基本 `vim.o`、テーブルが要る所だけ `vim.opt`」という kickstart の割り切りを踏襲する。

### D3: leader を今回スコープに含める

`vim.g.mapleader` は厳密にはオプションではなく、かつ「プラグイン読み込み前に設定必須」という制約を持つ。今回プラグインは無いため機能影響はゼロだが、次回 keymap/plugin を始める瞬間に必要になる。先に置くことで後の事故を防ぐ。`mapleader=" "`, `maplocalleader="\"`（leader と localleader を分離し衝突を避ける無難な構成）。

### D4: `showmode` は既定（true）のまま

LazyVim は `showmode=false` にするが、これはステータスラインプラグインがモード表示を肩代わりする前提。今回プラグインが無い状態で `false` にすると `-- INSERT --` がどこにも表示されなくなる。statusline 導入の回で `false` に倒す。

### D5: `clipboard="unnamedplus"` を単純固定

LazyVim は SSH 時に OSC52 へ委ねる小技を持つが、今回はローカル運用前提のため単純に `unnamedplus` を設定する。

### D6: `autoread` は値だけ設定、実効化 autocmd は次回

将来 AI Agent が裏でファイルを書き換える運用では、外部変更の自動リロードが重要になる。`autoread` オプションは今回入れておくが、実際に変更を検知するための `checktime` を叩く autocmd（FocusGained / CursorHold）は autocmd 回のスコープとして分離する。今回は伏線として値のみ置く。

## Risks / Trade-offs

- [`autoread` だけ入れても autocmd が無ければ自動リロードは効かない] → 今回は意図的に値のみ。実効化は autocmd 回で行う旨を spec のスコープ外要件に明記済み。
- [XDG 配置で既存パッケージとパス流儀が異なる] → `neovim/.config/nvim/...` という一段深い構成。README に配置意図を記し混乱を避ける。
- [`maplocalleader="\"` の Lua エスケープ] → Lua 文字列では `"\\"` と書く必要がある。実装時に注意。

## Migration Plan

1. `neovim/.config/nvim/init.lua`、`lua/config/options.lua`、`neovim/README.md` を作成。
2. リポジトリルートで `stow -n neovim`（ドライラン）で衝突が無いことを確認。
3. `stow neovim` で展開。
4. `nvim` を起動し、オプションが反映されること、エラーが出ないことを確認。
5. ロールバック: `stow -D neovim` でシンボリックリンクを除去すれば原状復帰。

## Open Questions

- なし（オプション集合・構成・命名は探索フェーズで確定済み）。
