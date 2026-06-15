-- autocmd 設定。プラグイン非依存の autocmd のみを定義する。
-- 再ソースしても二重登録されないよう、clear=true の augroup でグループ化する。

local function augroup(name)
  return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

local autocmd = vim.api.nvim_create_autocmd

-- ── autoread 実効化（checktime）──────────────────────────
-- autoread は mtime を「見に行った瞬間」しかリロードしない。フォーカス復帰や
-- 端末コマンド終了という「意味のある瞬間」に checktime を叩いて実効化する。
-- CursorHold は updatetime ごとに頻発するため使わない。tmux ペイン間で
-- FocusGained を効かせる focus-events 設定は tmux パッケージ回で扱う。
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
  desc = "外部変更を取り込むため checktime を実行",
})

-- ── 外部変更リロードの通知 ───────────────────────────────
-- 静かなリロードに気づけるよう、取り込み後に通知を出す（AI Agent 運用向け）。
autocmd("FileChangedShellPost", {
  group = augroup("file_changed_notify"),
  callback = function()
    vim.notify("外部でファイルが変更されました（バッファを再読み込み）", vim.log.levels.WARN)
  end,
  desc = "外部変更の取り込みを通知",
})

-- ── ヤンクハイライト ─────────────────────────────────────
autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank()
  end,
  desc = "ヤンク範囲を一時ハイライト",
})

-- ── カーソル位置の復元 ───────────────────────────────────
-- gitcommit/gitrebase は先頭にいたいので除外。マーク行が範囲外ならスキップ。
autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit", "gitrebase" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "前回のカーソル位置へ復帰",
})

-- ── 分割の均等化 ─────────────────────────────────────────
-- tabdo は全タブを巡るので、操作後に元のタブへ戻す。
autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
  desc = "リサイズ時に分割を均等化（現在タブを保持）",
})

-- ── 一時バッファを q で閉じる ────────────────────────────
-- q はマクロ記録の重要キー。グローバルに奪わず、対象 filetype の
-- バッファに限定して上書きする。プラグイン由来の filetype は導入時に追加する。
autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "help", "qf", "man", "checkhealth" },
  callback = function(event)
    vim.keymap.set("n", "q", "<cmd>close<cr>", {
      buffer = event.buf,
      silent = true,
      desc = "ウィンドウを閉じる",
    })
  end,
  desc = "一時バッファを q で閉じる",
})

-- ── 保存時の親ディレクトリ自動作成 ───────────────────────
autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(event)
    -- oil:// など URI 形式のバッファ名は実ディレクトリを作らない。
    if event.match:match("^%w+://") then
      return
    end
    vim.fn.mkdir(vim.fn.fnamemodify(event.match, ":p:h"), "p")
  end,
  desc = "保存時に親ディレクトリを作成",
})

-- ── コメント継続の無効化 ─────────────────────────────────
-- ftplugin の後に走るため上書きが効く。改行時のコメント自動挿入を止める。
autocmd("FileType", {
  group = augroup("no_comment_continuation"),
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
  desc = "改行時のコメント自動継続を無効化",
})
