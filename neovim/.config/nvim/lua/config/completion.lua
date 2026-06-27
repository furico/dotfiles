-- 補完。blink.cmp を使う。
-- blink はタグにピンすると prebuilt の fuzzy バイナリを自動取得する（cargo 不要）。
-- prefer_rust_with_warning なので、取得・ロードに失敗しても警告のうえ Lua 実装に
-- フォールバックして補完は動き続ける。LSP への capabilities 提供は lsp.lua 側が
-- require("blink.cmp").get_lsp_capabilities() で受け取る。
--
-- 未インストール（初回オフライン等）でも起動を壊さないよう pcall で保護する。

local ok, blink = pcall(require, "blink.cmp")
if not ok then
  return
end

blink.setup({
  keymap = { preset = "default" },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})
