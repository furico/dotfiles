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
  -- 検証用 colorscheme。termguicolors（options.lua）と合わせて
  -- 「インストール → 起動時適用」を見た目で確認できる最小の実プラグイン。
  { src = gh("folke/tokyonight.nvim"), name = "tokyonight" },

  -- 構文ハイライト・折りたたみ。main ブランチ（組み込み vim.treesitter に
  -- 委譲する書き直し版）を使う。default が legacy master のため version を明示。
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
})

-- ── 初期化 ───────────────────────────────────────────────
-- 未インストール（初回オフライン等）でも起動を壊さないよう pcall で保護する。
local ok = pcall(vim.cmd.colorscheme, "tokyonight")
if not ok then
  vim.notify("colorscheme 'tokyonight' を適用できませんでした（未インストール？）", vim.log.levels.WARN)
end

-- ── プラグイン管理 keymap（<leader>p 名前空間）───────────
-- vim.pack 依存のため keymaps.lua ではなくここに置き capability を自己完結させる。
local map = vim.keymap.set

map("n", "<leader>pu", function() vim.pack.update() end, { desc = "プラグインを更新（確認バッファ）" })
map("n", "<leader>ps", function() vim.pack.update(nil, { offline = true }) end, { desc = "プラグインの現状を確認（オフライン）" })

-- ── プラグイン個別設定 ───────────────────────────────────
-- 「レジストリに追加 + 専用 config モジュール」パターン。以降のプラグインも同様。
require("config.treesitter")
