-- 基本オプション設定。
-- 書き方は vim.o を基本とし、テーブル値が必要な箇所のみ vim.opt を使う。

-- ── leader ───────────────────────────────────────────────
-- プラグイン読み込み前に設定する必要があるため最初に置く。
-- mapleader と maplocalleader を分離して衝突を避ける。
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local o = vim.o

-- ── 表示 ─────────────────────────────────────────────────
o.number = true -- 絶対行番号
o.relativenumber = true -- 相対行番号
o.cursorline = true -- カーソル行をハイライト
o.signcolumn = "yes" -- sign column を常時表示（テキストのズレ防止）
o.scrolloff = 10 -- カーソル上下に最低限残す行数
o.termguicolors = true -- truecolor
o.wrap = false -- 折り返さない
-- showmode は既定（true）のまま。statusline プラグイン導入時に false へ。

-- 不可視文字の表示
o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- ── インデント ───────────────────────────────────────────
o.expandtab = true -- タブをスペースに展開
o.shiftwidth = 2 -- 自動インデント幅
o.tabstop = 2 -- タブの表示幅
o.smartindent = true -- 構文に応じた自動インデント
o.shiftround = true -- インデントを shiftwidth の倍数に丸める
o.breakindent = true -- 折り返し行のインデントを揃える

-- ── 検索 ─────────────────────────────────────────────────
o.ignorecase = true -- 大文字小文字を無視
o.smartcase = true -- 大文字を含む場合は区別
o.inccommand = "split" -- :substitute の置換をプレビュー

-- ── 編集・ファイル ───────────────────────────────────────
o.undofile = true -- undo 履歴を永続化
o.undolevels = 10000
o.confirm = true -- 未保存終了時に確認ダイアログ
o.mouse = "a" -- マウス有効
o.clipboard = "unnamedplus" -- システムクリップボードと共有
o.autoread = true -- 外部変更を自動で取り込む（実効化の autocmd は別途）
o.updatetime = 250 -- CursorHold 等の発火間隔
o.timeoutlen = 300 -- マッピング待ち時間

-- ── 分割 ─────────────────────────────────────────────────
o.splitright = true -- 縦分割を右に
o.splitbelow = true -- 横分割を下に
