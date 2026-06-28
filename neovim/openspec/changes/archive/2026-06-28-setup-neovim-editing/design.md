## Context

LSP・補完・finder・ファイラまで整い、残る大きな日常体感の穴が「編集 QoL」= auto-pairs と surround。repo は純 Lua・build 不要・1プラグイン1役・pcall 保護・vim.pack ネイティブ・キー衛生（`q` 温存、LSP 既定を壊さない等）を一貫して守ってきた。mini 系（`echasnovski/*`）はこの価値観に最も近い候補。

確認済みの事実:
- blink.cmp の `default` preset（`completion.lua` で採用）は `<CR>` を確定に使わない（確定 `<C-y>`、移動 `<C-n>/<C-p>`、スニペット `<Tab>`）。よって mini.pairs の `<CR>` マッピングと補完は競合しない。

## Goals / Non-Goals

**Goals:**
- auto-pairs（mini.pairs）と surround（mini.surround）を最小構成で導入し、既定挙動のまま日常編集を底上げする。
- 1プラグイン1役・専用モジュール集約・pcall 保護の既存方針を踏襲する。
- 補完（blink）とのキー競合を持ち込まない。

**Non-Goals:**
- フォーマッタ（今回除外）・Linter。
- mini の他モジュール（mini.ai / move / comment / files 等）の導入。
- mini.pairs/surround のキー・規則のカスタム作り込み（既定を採用）。
- treesitter 連動の賢い auto-pairs（nvim-autopairs）。

## Decisions

### 決定1: standalone 2リポジトリ（フル mini.nvim ではなく）

`echasnovski/mini.pairs` と `echasnovski/mini.surround` を個別に `vim.pack.add` する。フル `mini.nvim` は1ロックエントリで将来 mini.ai/move 等も無料になる（snacks 的）が、未使用モジュールのコードも disk に乗り、「1プラグイン1役・最小・必要分だけ」という repo の他プラグイン（treesitter/lsp/finder…）の流儀から外れる。

- 代替案（フル mini.nvim）: 将来 mini モジュールを足すなら lock エントリが増えない利点。だが現時点で必要なのは2つだけで、YAGNI。将来必要になれば monorepo へ寄せ替えは容易。却下。
- 採用案（standalone）: 各プラグインが単機能で既存方針と一致。lock も使う分だけ。

### 決定2: mini.pairs / mini.surround の既定をそのまま採用

mini.pairs は `setup({})` の既定（`( [ { " ' \`` の auto-pair、`<BS>` ペア削除、`<CR>` ペア間改行）を使う。mini.surround は `s*` 既定マッピング（`sa`/`sd`/`sr`/`sf`/`sF`/`sh`）を使う。キーや規則のカスタムは持ち込まない（必要が出たら別途）。

- mini.pairs は treesitter 非依存で、文字列/コメント内でも素朴にペアを足す。nvim-autopairs はそこが賢いが重く依存も増える。dotfiles 編集（lua/sh/md/json/yaml/toml）では素朴な実装で十分と判断。

### 決定3: surround は `s*` 既定を受け入れ（`s` の別プレフィックス移設はしない）

mini.surround 既定の `s` プレフィックスは組み込み `s`（=`cl`、1文字置換）を覆うが、押下後 `timeoutlen`（300ms）待って `s` 単独へフォールバックするため完全には失わない。`cl` で代替でき実害が小さいこと、mini 公式デフォルトで資料・学習コストが最小であることから、別プレフィックス（`gs` 等）への移設はしない。

- 代替案（`gs` 等へ移設し `s` 温存）: キー衛生は最大化するが、既定から外れて学習・保守コストが増える。今回は採らない（将来不満が出れば移設は容易）。

### 決定4: 1 capability `neovim-editing` / 1 モジュール `editing.lua`、setup は独立 pcall

auto-pairs と surround は「編集 QoL」の対として1 capability にまとめ、`lua/config/editing.lua` に両 setup を載せる。ただし各 `setup` は独立に `pcall` 保護し、片方が未導入でも他方が動く。

### 決定5: which-key の `s`=surround グループは ui.lua に登録（neovim-ui のデルタ）

finder（`<leader>f`）・hunks（`<leader>h`）と同じく、group 名は `ui.lua` の `wk.add` に集約し、実マッピングは mini.surround 既定に委ねる。これにより `s` 押下時のポップアップで surround サブキーが見やすくなる。`neovim-ui` の which-key 要件のみを最小追記する。

## Risks / Trade-offs

- [mini.pairs の `<CR>` が補完を誤確定する] → blink `default` preset は `<CR>` 不使用と確認済み。動作確認（補完表示中の `<CR>`）で担保。将来 blink を `enter` preset に変えるなら再検討が必要、と README に注記。
- [`s` プレフィックスで `s` 単独操作が遅延/混乱] → `s`≈`cl` で代替可能。違和感が出れば `editing.lua` の mappings を別プレフィックスへ寄せられる（設計上の逃げ道を残す）。
- [mini.pairs が文字列/コメント内で不要なペアを足す] → treesitter 非依存ゆえの既知の割り切り。実害が大きければ nvim-autopairs へ差し替える別 change を立てる。
- [未導入（初回オフライン）での起動] → `require("config.editing")` と各 `setup` を `pcall` 保護。機能無しで起動・編集を継続（spec のシナリオで担保）。
