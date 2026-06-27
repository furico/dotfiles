## Context

`setup-neovim-plugins`（vim.pack 土台）→ treesitter → lsp と積んできた機能プラグイン群に続く UI/QoL 回。環境は nvim 0.12.3。本 change のプラグインはいずれも純 Lua で **build ステップ・外部バイナリ依存なし**。前回までと違い、`PackChanged` build フックや prebuilt 取得の配線は不要で、`vim.pack.add` + setup だけで完結する。

既存の伏線:
- `options.lua`: `showmode` は既定（true）のまま、「statusline プラグイン導入時に false へ」とコメント済み（値設定はしていない）。
- `keymaps` spec: 「`desc` は which-key 導入時にゼロコストで効く」「`<leader>` 系はプラグイン導入回で扱う」と先送り。
- `autocmds` proposal: 「末尾空白トリムは gitsigns / conform.nvim の粒度が来る回へ先送り」。

## Goals / Non-Goals

**Goals:**
- statusline・インデントガイド・キーマップポップアップ・git sign/hunk 操作で見た目と操作性を底上げする。
- 検証用 colorscheme（tokyonight）を本命の catppuccin へ格上げし、配色を UI レイヤの責務にする。
- 既存の伏線（showmode、desc/which-key、leader 名前空間）を回収する。
- 「組み込み優先・薄い宣言層・専用 config モジュール」路線を維持し、未導入・オフラインでも起動を壊さない。

**Non-Goals:**
- ファイラ・bufferline・dashboard・通知・大型 QoL バンドル（snacks 等）。
- フォーマッタ/linter、**末尾空白トリム**（conform 回）。
- ハイライトグループの手作り込みや、catppuccin の細かな integration チューニング（まず素の mocha で入れる）。
- tmux 側のテーマ適用（tmux パッケージのスコープ。本 change では nvim 配色のみ）。

## Decisions

### D1: 4プラグインとも build 不要・default ブランチで導入

`lualine.nvim` / `which-key.nvim` / `gitsigns.nvim` / `indent-blankline.nvim` はすべて純 Lua。`vim.pack.add` で `version` を省略し default ブランチを使う（tokyonight と同じ扱い）。build フックや prebuilt 取得は不要。treesitter/blink のような特殊配線が要らないぶん、`plugins.lua` への登録 + setup だけで済む。

代替: 各プラグインを tag/semver でピン → 今回は見送り。安定志向のプラグインで、lockfile が revision を固定するため再現性は確保される。破壊的変更が問題化したら個別にピンを足す。

### D2: capability は neovim-ui と neovim-git の2本

「見た目・操作性の UI レイヤ（lualine + indent-blankline + which-key）」と「git 統合（gitsigns）」は関心が異なる。前者を `neovim-ui`、後者を `neovim-git` に分ける。gitsigns は sign 表示だけでなく hunk 操作キーマップ（`<leader>h` 系）と blame を持つため、純 UI ではなく git 機能として独立させるのが自然。

### D3: モジュール分割（ui.lua / git.lua）

capability 分割に対応して `lua/config/ui.lua`（lualine + ibl + which-key + showmode=false）と `lua/config/git.lua`（gitsigns）を作る。`plugins.lua` の末尾で `require("config.ui")` → `require("config.git")` する（順序依存はないが UI を先に）。各 setup は `pcall` で保護し、未導入時は早期 return / 無害化する。

### D4: showmode=false は ui.lua に置き、options.lua はコメント更新のみ

`showmode` は `options.lua` では値を設定しておらず（既定 true のまま）、コメントで「statusline 導入時に false へ」と予約していただけ。lualine がモードを表示するので組み込みのモード表示は冗長になる。`vim.o.showmode = false` を **lualine と同じ関心として `ui.lua`** に置く。`options.lua` 側は予約コメントを「ui.lua で false 設定済み」へ更新するのみ。これにより `neovim-options` の要件は変えず、Modified capability を発生させない。

### D5: which-key は v3、グループ登録に新 API を使う

`which-key.nvim` は v3 で API が変わっている（`wk.register` → `wk.add` 系）。実装直前に現物 README で `setup` とグループ登録（`<leader>p`=plugins、`<leader>h`=hunks など）の正確な記法を確認してから書く。which-key は既存の `desc` を自動で拾うため、グループ名（プレフィックスのラベル）だけ与えれば良い。which-key 不在でも `desc` 自体は無害なので、`pcall` 保護で十分。

### D6: indent-blankline は v3（モジュール名 ibl）

`indent-blankline.nvim` は v3 でモジュール名が `ibl` に変わり、`require("ibl").setup({})` で初期化する。スコープ/コンテキスト表示などの作り込みはせず、まず素のガイド表示で入れる。

### D7: gitsigns の hunk キーマップは on_attach でバッファローカル

`gitsigns.setup({ on_attach = function(bufnr) ... end })` 内で、git 管理下のバッファにのみ hunk 操作を付ける。最小セット: hunk ナビ `]c`/`[c`（差分がない時はノーマルの `]c` にフォールバック）、`<leader>h` 系で stage/reset/preview hunk・stage/reset buffer・blame line・toggle。すべて `desc` 付き・`{ buffer = bufnr }`。`<leader>h`=hunks のグループ名は which-key 側（ui.lua）で登録する（capability は跨ぐが、グループ登録は which-key の関心なので ui.lua に集約）。`keymaps.lua` は plugin-free のまま。

### D8: lualine theme は auto

`require("lualine").setup({ options = { theme = "auto" } })` で現在の colorscheme（catppuccin）に追従させる。テーマ名をハードコードせず、将来 colorscheme を差し替えても statusline が自動追従する。`showmode=false` と合わせ、モード表示は lualine セクションに一本化。

### D9: colorscheme を catppuccin へ格上げし、neovim-ui の責務にする

`setup-neovim-plugins` で入れた tokyonight は「差し替え可能な検証用 colorscheme」（plugins design D3）であり、plugins.lua にインライン適用していた。本 change で本命の `catppuccin/nvim`（flavour=mocha）へ差し替え、配色を UI レイヤの責務へ格上げする。

- **配置**: catppuccin の setup と適用は `ui.lua` の先頭（lualine より前）に置く。lualine `theme="auto"`（D8）が適用済みの colorscheme を検出できるようにするため、`require("catppuccin").setup({ flavour = "mocha" })` → `vim.cmd.colorscheme("catppuccin")` を lualine setup より前に行う。適用は `pcall` で保護し、未導入でも起動を壊さない（tokyonight でやっていたフォールバックを catppuccin で踏襲）。
- **registry**: `plugins.lua` の `vim.pack.add` から tokyonight を外し、catppuccin を足す。repo は `catppuccin/nvim` で dir 名が `nvim` になってしまうため `name = "catppuccin"` を明示する（tokyonight で name を明示したのと同じ理由）。plugins.lua にあった tokyonight 適用ブロック（`pcall(vim.cmd.colorscheme, "tokyonight")`）は削除する。
- **spec への影響**: `neovim-plugins` の「検証用 colorscheme の起動時適用」要件を REMOVED し、`neovim-ui` に「colorscheme（catppuccin）の適用」要件を ADDED する。配色の責務が plugins レジストリ層から UI 層へ移動する。
- **catppuccin 選定理由**: nvim/tmux/他アプリを横断で揃える思想で、公式 `catppuccin/tmux` があるため、将来の tmux テーマ回で同系統に揃えられる（tmux 自体は本 change のスコープ外）。lualine・treesitter・gitsigns・which-key・mason・blink 等とは catppuccin の integration が自動で噛み合う。
- **flavour**: ダークの既定 `mocha`。将来 macchiato/frappe/latte へ変えるのは setup の1値変更で済む。

代替: tokyonight のバリアント変更のみ → 却下（ユーザー選択は catppuccin。tmux 横断テーマの相性を優先）。

## Risks / Trade-offs

- [which-key v3 / ibl v3 の API 変更] → 実装直前に現物 README で setup・グループ登録の記法を確認（D5/D6）。設定は ui.lua の1ファイルに隔離。
- [gitsigns の `]c`/`[c` が diff モードの組み込み `]c`/`[c` と競合] → gitsigns 推奨どおり、diff モード時は組み込みにフォールバックする実装にする。
- [default ブランチ追従で将来 breaking change が入る] → lockfile が revision を固定。更新は `<leader>pu` の確認バッファ経由なので、壊れたら戻せる。必要なら個別ピン。
- [statusline/indent ガイドが特定 filetype（dashboard 等）で邪魔] → 今回はファイラ/dashboard 未導入なので影響小。導入時に除外リストを足す。
- [which-key 不在・未導入時] → `pcall` 保護。`desc` は which-key 非依存で無害なので、ポップアップが出ないだけで他機能に波及しない。

## Migration Plan

1. `lua/config/ui.lua` を作成（先頭で catppuccin setup[flavour=mocha] + `colorscheme catppuccin` を pcall 適用、続いて lualine setup[theme=auto]、`require("ibl").setup`、which-key setup + `<leader>p`/`<leader>h` グループ登録、`vim.o.showmode=false`）。
2. `lua/config/git.lua` を作成（gitsigns setup、on_attach の hunk キーマップ）。
3. `plugins.lua` の `vim.pack.add` に catppuccin（`name="catppuccin"`）と他4プラグインを追加し、tokyonight を削除。tokyonight 適用ブロックを削除し、末尾で `require("config.ui")` → `require("config.git")`。
4. `options.lua` の showmode 予約コメントを更新。
5. `nvim` を起動 → 4プラグイン clone。statusline 表示、インデントガイド、which-key ポップアップ、git sign を確認。
6. git 管理下のファイルで hunk ナビ・`<leader>h` 操作・blame を確認。
7. lockfile に4プラグインの revision が追記されたことを確認し `git add`。
8. `README.md` に UI/git の節を追記。
9. ロールバック: `plugins.lua` の4行と require 2行を戻し、`ui.lua`/`git.lua` 削除、`options.lua` のコメントを戻し、`vim.pack.del({...})`、ロックファイルを `git checkout`。

## Open Questions

- なし（プラグイン選定・capability 分割・モジュール構成・showmode の置き場所はユーザー確認および既存伏線から確定済み。v3 系 API は実装直前に現物確認）。
