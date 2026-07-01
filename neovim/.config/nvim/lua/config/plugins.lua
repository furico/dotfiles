-- プラグイン管理。Neovim 0.12 組み込みの vim.pack を土台にする。
-- 外部マネージャ（lazy.nvim 等）は使わず、bootstrap も持たない。
-- vim.pack.add で宣言的に列挙し、直後に最小の初期化だけを行う薄い層。
-- ロックファイルは ~/.config/nvim/nvim-pack-lock.json に生成され、
-- ~/.config/nvim が repo への folded symlink のため実体は repo 内に落ちる。
-- 手編集せず vim.pack.update() の確認バッファ経由でのみ更新する。

-- src を短く書くためのヘルパ。完全な https URL を返すので、
-- ロックファイルにも完全な URL が残り可搬性を保てる（git insteadOf は使わない）。
local function gh(repo)
  return "https://github.com/" .. repo
end

-- ── プラグイン登録 ───────────────────────────────────────
vim.pack.add({
  -- colorscheme。catppuccin（mocha）。適用は ui.lua（lualine より前）で行う。
  -- repo 名が nvim のため dir 名衝突を避けて name を明示する。
  { src = gh("catppuccin/nvim"), name = "catppuccin" },

  -- 構文ハイライト・折りたたみ。main ブランチ（組み込み vim.treesitter に
  -- 委譲する書き直し版）を使う。default が legacy master のため version を明示。
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },

  -- LSP。組み込み vim.lsp を土台に、サーバ調達を mason に任せる。
  -- nvim-lspconfig は lsp/*.lua 設定データ供給源、mason-lspconfig は橋渡し +
  -- automatic_enable による vim.lsp.enable を担う。
  { src = gh("mason-org/mason.nvim") },
  { src = gh("neovim/nvim-lspconfig") },
  { src = gh("mason-org/mason-lspconfig.nvim") },

  -- 補完。タグにピンして prebuilt の fuzzy バイナリを得る（cargo 不要）。
  { src = gh("Saghen/blink.cmp"), version = vim.version.range("1") },

  -- UI/QoL。いずれも純 Lua で build 不要、default ブランチ。
  { src = gh("nvim-lualine/lualine.nvim") },
  { src = gh("folke/which-key.nvim") },
  { src = gh("lewis6991/gitsigns.nvim") },
  { src = gh("lukas-reineke/indent-blankline.nvim") },

  -- fuzzy finder。snacks の picker モジュールのみを finder.lua で有効化する。
  -- 純 Lua・build 不要・外部バイナリ不要（rg/fd があれば速い）、default ブランチ。
  { src = gh("folke/snacks.nvim") },

  -- 編集 QoL。auto-pairs と surround。mini モノレポではなく standalone 2 つを
  -- 個別に取る（1 プラグイン 1 役）。いずれも純 Lua・build 不要、default ブランチ。
  { src = gh("echasnovski/mini.pairs") },
  { src = gh("echasnovski/mini.surround") },
})

-- ── プラグイン管理 keymap（<leader>p 名前空間）───────────
-- vim.pack 依存のため keymaps.lua ではなくここに置き capability を自己完結させる。
local map = vim.keymap.set

map("n", "<leader>pu", function() vim.pack.update() end, { desc = "プラグインを更新（確認バッファ）" })
map("n", "<leader>ps", function() vim.pack.update(nil, { offline = true }) end, { desc = "プラグインの現状を確認（オフライン）" })

-- ── プラグイン個別設定 ───────────────────────────────────
-- 「レジストリに追加 + 専用 config モジュール」パターン。以降のプラグインも同様。
require("config.treesitter")
-- 補完 → LSP の順。LSP 側が補完エンジンの capabilities を受け取るため先に補完を読む。
require("config.completion")
require("config.lsp")
-- UI（colorscheme/statusline/インデント/which-key）→ git（gitsigns）。
require("config.ui")
require("config.git")
-- snacks（中央 setup）→ finder（picker keymap）→ explorer（explorer keymap）の順。
-- setup を snacks.lua に集約し、各 capability はキーマップだけを足す。
-- <leader>f グループ名は ui.lua 側で登録済み。<leader>e/<leader>E は単独キーで登録不要。
require("config.snacks")
require("config.finder")
require("config.explorer")
-- lazygit 連携（snacks の lazygit モジュール）。<leader>g=git グループ名は ui.lua 側で登録済み。
require("config.lazygit")
-- 編集 QoL（mini.pairs / mini.surround）。s=surround グループ名は ui.lua 側で登録済み。
require("config.editing")
