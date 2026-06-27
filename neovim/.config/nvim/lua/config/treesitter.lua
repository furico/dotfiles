-- nvim-treesitter（main ブランチ）の設定。
-- main は組み込み vim.treesitter に土台を委譲する書き直し版で、ハイライト・
-- 折りたたみ・インデントは自前で配線する。プラグイン本体の vim.pack.add は
-- plugins.lua の中央レジストリにあり、ここはその固有設定だけを持つ。
--
-- パーサは C ソースをコンパイルして ~/.local/share/nvim/site/parser/ に入る
-- （C コンパイラが要る）。未ビルド・オフライン・コンパイラ不在でも起動が
-- 壊れないよう、利用箇所は pcall で保護する。

-- ── 対象言語 ─────────────────────────────────────────────
-- この dotfiles repo で実際に編集するものを中心に。追加はこの1行に足すだけ。
local langs = {
  "lua", "vim", "vimdoc", "query",
  "bash",
  "markdown", "markdown_inline",
  "json", "yaml", "toml",
  "diff", "gitcommit",
}

-- 実験的インデント（main の indentexpr）の on/off はここで一元管理する。
-- 誤インデントが出たら false にすれば options.lua の smartindent 既定へ戻る。
local enable_indent = true

-- ── パーサの install / 更新 ──────────────────────────────
-- 対象言語のうち未導入のものだけを非同期で入れる（冪等。起動はブロックしない）。
local function install_parsers()
  local ok, nts = pcall(require, "nvim-treesitter")
  if ok then
    pcall(function() nts.install(langs) end)
  end
end

-- 起動時に欠けたパーサを補う。
install_parsers()

-- プラグイン更新時はパーサと query を整合させる必要がある（:TSUpdate）。
-- vim.pack の PackChanged で install/update を捕まえて配線する。
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("config.treesitter.pack", { clear = true }),
  callback = function(ev)
    local d = ev.data
    if not (d and d.spec and d.spec.name == "nvim-treesitter") then
      return
    end
    if d.kind ~= "install" and d.kind ~= "update" then
      return
    end
    -- フックがプラグインのコードに依存するので、未ロードなら先に読み込む。
    if not d.active then
      pcall(vim.cmd.packadd, "nvim-treesitter")
    end
    install_parsers()
    if d.kind == "update" then
      pcall(vim.cmd, "silent! TSUpdate")
    end
  end,
})

-- ── ハイライト・fold・indent の配線 ──────────────────────
-- 開いた直後に折りたたまれないよう、新規ウィンドウは展開側で開始する。
vim.o.foldlevelstart = 99

-- FileType * で treesitter の開始を試み、成功したバッファにだけ fold/indent を
-- 設定する。パーサ名 ≠ filetype のズレを気にせず、導入済みパーサに自動追従する。
-- 非対象ファイルでは start() が失敗（pcall=false）し、fold/indent は触らない。
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config.treesitter.ft", { clear = true }),
  callback = function()
    if not pcall(vim.treesitter.start) then
      return
    end
    -- 折りたたみ（treesitter が有効なウィンドウに限定）。
    vim.wo[0][0].foldmethod = "expr"
    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    -- 実験的インデント（バッファローカル）。
    if enable_indent then
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
