## 1. 補完モジュール（blink.cmp）

- [x] 1.1 `neovim/.config/nvim/lua/config/completion.lua` を新設する
- [x] 1.2 `require("blink.cmp").setup({...})` を `pcall` 保護で呼び、`keymap = { preset = "default" }`、`sources.default = {"lsp","path","snippets","buffer"}`、`fuzzy.implementation = "prefer_rust_with_warning"` を設定する

## 2. LSP モジュール

- [x] 2.1 `neovim/.config/nvim/lua/config/lsp.lua` を新設する
- [x] 2.2 `require("mason").setup()` を `pcall` 保護で呼ぶ
- [x] 2.3 `vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })` を mason-lspconfig より前に設定する（取得は pcall 保護、失敗時は capabilities 無しで継続）
- [x] 2.4 `require("mason-lspconfig").setup({ ensure_installed = { "lua_ls","bashls","jsonls","yamlls","taplo" }, automatic_enable = true })` を `pcall` 保護で呼ぶ（サーバ一覧は1リストで一元管理）
- [x] 2.5 `vim.diagnostic.config({...})` で最小の妥当な診断表示（virtual_text 等）を設定する
- [x] 2.6 `clear=true` の専用 augroup + `LspAttach` autocmd で、バッファローカルに不足分のキーマップ（例 `gd` = `vim.lsp.buf.definition`）を `desc` 付きで足す（0.11+ デフォルトは再定義しない）

## 3. レジストリ結線

- [x] 3.1 `plugins.lua` の `vim.pack.add` に mason.nvim / nvim-lspconfig / mason-lspconfig.nvim / blink.cmp を追加する（blink は `version` で v1 系タグに semver range ピン）
- [x] 3.2 `plugins.lua` 末尾で `require("config.completion")` → `require("config.lsp")` の順に読み込む

## 4. 動作確認

- [x] 4.1 `nvim` を起動し、4プラグインの clone と mason のサーバ DL、blink の prebuilt 取得が走ることを確認する
- [x] 4.2 lua ファイルを開き `lua_ls` がアタッチすること（`vim.lsp.get_clients`）と、クライアントの capabilities に補完 capability が乗っていることを確認する
- [x] 4.3 挿入モードで補完候補が出ること、`K`（ホバー）・診断（`vim.diagnostic`）が効くことを確認する
- [x] 4.4 `LspAttach` の補助キーマップ（`gd` 等）がバッファローカルに付くことを確認する
- [x] 4.5 プラグイン/サーバ未導入を模した状態でも起動が壊れないこと（pcall フォールバック）を確認する
- [x] 4.6 再ソースで `LspAttach` augroup が二重登録されないことを確認する

## 5. ロックファイルとドキュメント

- [x] 5.1 ロックファイル `nvim-pack-lock.json` に4プラグインの revision が追記されたことを確認し `git add` する
- [x] 5.2 `neovim/README.md` に LSP/補完の節を追記する（mason によるサーバ調達と `ensure_installed` 再現方針、blink の prebuilt/Lua フォールバック、デフォルト + `gd` キーマップ、サーバのランタイム前提、サーバ実体は repo 外）
