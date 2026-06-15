-- init.lua はロード順を決めるだけの薄いローダ。
-- オプションの実体定義は lua/config/ 配下のモジュールに置く。
--
-- 将来の拡張時はここに require を足すだけでよい:
--   require("config.lazy")    -- プラグイン管理を入れる場合

require("config.options")
require("config.keymaps")
require("config.autocmds")
