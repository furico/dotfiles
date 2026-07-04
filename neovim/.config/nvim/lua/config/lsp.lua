-- LSP。設定の中心は組み込み vim.lsp（vim.lsp.config / vim.lsp.enable）に置く。
-- 役割分担:
--   mason.nvim          … サーバ（バイナリ）の調達
--   nvim-lspconfig      … 各サーバの設定データ（lsp/*.lua）供給源
--   mason-lspconfig     … mason 名 ↔ lspconfig 名の橋渡し + automatic_enable で
--                         インストール済みサーバを vim.lsp.enable() 有効化
-- 補完は blink.cmp が担うため vim.lsp.completion.enable は使わない。
-- 未インストール・サーバ未導入・ランタイム不在でも起動を壊さないよう保護する。

-- ── サーバ調達（mason）───────────────────────────────────
pcall(function()
  require("mason").setup()
end)

-- ── 補完 capability を全サーバの既定へ配線 ───────────────
-- mason-lspconfig の automatic_enable（vim.lsp.enable）より「前」に設定し、
-- enable 時に解決される設定へ確実に含める。blink 不在時は capabilities 無しで継続。
local function blink_capabilities()
  local ok, blink = pcall(require, "blink.cmp")
  if ok and type(blink.get_lsp_capabilities) == "function" then
    return blink.get_lsp_capabilities()
  end
  return nil
end

vim.lsp.config("*", { capabilities = blink_capabilities() })

-- ── Python venv 検出（basedpyright）─────────────────────
-- 新規プラグインは足さず、before_init で pythonPath を解決するだけに留める。
-- 優先順位: $VIRTUAL_ENV → root_dir/.venv → root_dir/venv → 何もしない（PATH の python3 に委ねる）。
local function find_venv_python(root_dir)
  local venv = os.getenv("VIRTUAL_ENV")
  if venv and vim.uv.fs_stat(venv .. "/bin/python") then
    return venv .. "/bin/python"
  end
  if not root_dir then
    return nil
  end
  for _, dir in ipairs({ ".venv", "venv" }) do
    local python = root_dir .. "/" .. dir .. "/bin/python"
    if vim.uv.fs_stat(python) then
      return python
    end
  end
  return nil
end

vim.lsp.config("basedpyright", {
  -- client.settings は Client.create 時に config.settings への参照として束縛される
  -- （vim.lsp.client 実装で確認済み）。ここで config.settings を丸ごと再代入すると
  -- client.settings は古い参照のまま取り残され、workspace/configuration 応答に
  -- pythonPath が乗らない。既存テーブルへの破壊的代入で参照を保つ。
  before_init = function(_, config)
    local python_path = find_venv_python(config.root_dir)
    if python_path then
      config.settings = config.settings or {}
      config.settings.python = config.settings.python or {}
      config.settings.python.pythonPath = python_path
    end
  end,
})

-- ── サーバの調達リストと自動有効化 ───────────────────────
-- 追加はこの ensure_installed の1リストに足すだけ（lspconfig サーバ名）。
pcall(function()
  require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "bashls", "jsonls", "yamlls", "taplo", "basedpyright" },
    automatic_enable = true,
  })
end)

-- ── 診断表示 ─────────────────────────────────────────────
-- 最小の妥当なデフォルト。記号やフロート枠の作り込みは UI 回へ先送り。
vim.diagnostic.config({
  virtual_text = true,
  underline = true,
  severity_sort = true,
  update_in_insert = false,
})

-- ── LSP キーマップ ───────────────────────────────────────
-- nvim 0.11+ のデフォルト（grn/gra/grr/gri/K, [d/]d 等）は再定義せず、
-- 不足分だけ LspAttach でバッファローカルに補う。clear=true で冪等。
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("config.lsp.attach", { clear = true }),
  callback = function(ev)
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    map("gd", vim.lsp.buf.definition, "定義へ移動")
    map("gD", vim.lsp.buf.declaration, "宣言へ移動")
  end,
})
