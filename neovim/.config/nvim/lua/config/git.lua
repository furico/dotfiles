-- git 統合（gitsigns）。git の変更を sign 列に表示し、hunk 操作・blame を提供する。
-- 純 Lua で build 不要。未導入でも起動を壊さないよう pcall で保護する。
-- <leader>h=hunks のグループ名は which-key 側（ui.lua）で登録する。

local ok, gitsigns = pcall(require, "gitsigns")
if not ok then
  return
end

gitsigns.setup({
  -- git 管理下のバッファにのみバッファローカルキーマップを付ける。
  on_attach = function(bufnr)
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- ── hunk ナビ（diff モード時は組み込みの ]c/[c にフォールバック）──
    map("]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gitsigns.nav_hunk("next")
      end
    end, "次の hunk へ")
    map("[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gitsigns.nav_hunk("prev")
      end
    end, "前の hunk へ")

    -- ── hunk 操作（<leader>h 名前空間）────────────────────
    map("<leader>hs", gitsigns.stage_hunk, "hunk をステージ")
    map("<leader>hr", gitsigns.reset_hunk, "hunk を取り消し")
    map("<leader>hS", gitsigns.stage_buffer, "バッファ全体をステージ")
    map("<leader>hR", gitsigns.reset_buffer, "バッファ全体を取り消し")
    map("<leader>hp", gitsigns.preview_hunk, "hunk をプレビュー")
    map("<leader>hb", function() gitsigns.blame_line({ full = true }) end, "行の blame")
    map("<leader>hd", gitsigns.diffthis, "hunk を diff 表示")
    map("<leader>ht", gitsigns.toggle_current_line_blame, "行 blame の表示切替")
  end,
})
