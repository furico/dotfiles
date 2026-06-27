-- init.lua はロード順を決めるだけの薄いローダ。
-- オプションの実体定義は lua/config/ 配下のモジュールに置く。

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.plugins")
