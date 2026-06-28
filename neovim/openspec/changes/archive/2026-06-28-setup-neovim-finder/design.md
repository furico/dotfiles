## Context

`setup-neovim-plugins`（vim.pack 土台）→ treesitter → lsp → ui と積んできた系譜に続く「探す」回。環境は nvim 0.12.3。これまで移動・検索は組み込み（`:find`/`path`、`:grep`、`:buffers`、`gO`）に頼っており、プロジェクト規模での探索導線が弱かった。本 change は fuzzy finder を1枚入れてその起点を作る。

バックエンドは `folke/snacks.nvim` の picker モジュール。`neovim-ui` の spec は「snacks 等の大型 QoL バンドルは含まれない」と UI capability のスコープから snacks を**明示的に除外**していたが、これは UI レイヤに snacks を抱き込まない宣言であって、別 capability で picker 単独を入れることまで禁じてはいない。本 change は finder という独立 capability として、snacks の **picker モジュールのみ**を有効化する（dashboard/notifier 等は入れない）。

既存の伏線・前提:
- `ui.lua`: which-key のグループ名を `wk.add` に集約する方針（`<leader>h`=hunks の実キーマップは git.lua、group 名は ui.lua）。finder も同じ分離に従う。
- `keymaps.lua`: plugin-free を維持。finder のキーマップは finder.lua に置く。
- これまでの全プラグインと同じく純 Lua・build 不要・`pcall` 保護で未導入耐性。

## Goals / Non-Goals

**Goals:**
- ファイル検索・プロジェクト grep・バッファ/最近/ヘルプ/キーマップ/診断/シンボルの導線を `<leader>f` 名前空間で提供する。
- snacks の picker モジュール**だけ**を有効化し、他モジュールを持ち込まない。
- 「組み込み優先・薄い宣言層・専用 config モジュール」路線を維持し、未導入・オフラインでも起動を壊さない。
- group 名は ui.lua に集約する既存方針を踏襲する（`<leader>f`=find）。

**Non-Goals:**
- LSP ナビ（`gd`/`grr`/`gri` 等）の picker 置き換え（`neovim-lsp` の組み込みデフォルトは維持。シンボル一覧 `<leader>fs` の追加に留める）。
- ファイラ（oil/neo-tree）、git 専用 picker（`<leader>h` は gitsigns のまま）。
- snacks の picker 以外のモジュール（dashboard/notifier/scroll/indent/statuscolumn/animate 等）。
- picker レイアウト・ソート・preview の作り込み（まず素の既定で入れる）。

## Decisions

### D1: バックエンドは snacks.picker（picker のみ有効化）

候補は snacks.picker / telescope / fzf-lua。repo の価値観（純 Lua・build 不要・自己完結）に照らして snacks を選ぶ。

- **snacks.picker**: 純 Lua・C ビルド不要・外部バイナリ不要で最も自己完結。which-key と作者（folke）が揃い integration の相性が良い。難点は本体が多機能な大型プラグインである点だが、**picker 以外のモジュールは既定で無効**なので、setup で picker だけ有効化すれば表面積を抑えられる。
- 代替 telescope: 定番だが `plenary.nvim` 依存に加え、実用速度には `telescope-fzf-native`（C ビルド）が事実上必須で「build 不要」と相反。却下。
- 代替 fzf-lua: 高速だが `fzf` バイナリ（外部依存）が要る。単一バイナリで軽いが、自己完結性で snacks に劣る。却下。

`require("snacks").setup({ picker = { enabled = true } })` の形で picker のみ有効化する。他モジュールは明示的に列挙せず既定無効のままにする（将来モジュールを足す時に意図が読めるよう、有効化したものだけを setup に書く方針）。

### D2: capability は neovim-finder 単独 + neovim-ui の delta

finder は「探す」関心で独立した capability（`neovim-finder`）にする。which-key のグループ名登録（`<leader>f`=find）だけは ui.lua の `wk.add` に集約する既存方針（hunks の前例）に従うため、`neovim-ui` の which-key 要件を MODIFIED する。UI の他要件（colorscheme/lualine/ibl）は不変。

### D3: モジュール分割（finder.lua）

既存パターンに対応して `lua/config/finder.lua` を新設し、snacks.picker の setup と `<leader>f` キーマップ群をここに集約する。`plugins.lua` の `vim.pack.add` に snacks を足し、末尾の require 群に `require("config.finder")` を追記する（順序依存はない。lsp/ui/git と並ぶ位置）。setup・require は `pcall` 保護で未導入時は早期 return。

### D4: `<leader>f` キーマップ設計

`<leader>f`（=find）配下に集約し、snacks.picker の対応 API を関数呼び出しで束ねる。最小で実用的な10個:

| キー | 機能 | snacks API |
|------|------|-----------|
| `<leader>ff` | ファイル検索 | `Snacks.picker.files()` |
| `<leader>fg` | プロジェクト grep | `Snacks.picker.grep()` |
| `<leader>fw` | カーソル下の語で grep | `Snacks.picker.grep_word()` |
| `<leader>fb` | バッファ | `Snacks.picker.buffers()` |
| `<leader>fr` | 最近のファイル | `Snacks.picker.recent()` |
| `<leader>fh` | ヘルプ | `Snacks.picker.help()` |
| `<leader>fk` | キーマップ | `Snacks.picker.keymaps()` |
| `<leader>fd` | 診断 | `Snacks.picker.diagnostics()` |
| `<leader>fs` | ドキュメントシンボル | `Snacks.picker.lsp_symbols()` |
| `<leader>fl` | 直前の picker 再開 | `Snacks.picker.resume()` |

キーマップは `function() require("snacks").picker.files() end` 形式で遅延参照し、snacks 未ロードでも定義自体は無害にする（押下時に snacks が無ければ何もしない／エラーを握り潰す）。`desc` は which-key にそのまま出る日本語の短文にする。`gd`/`grr` 等の LSP ナビ既定は触らない（D 非Goal）。

### D5: which-key の `<leader>f` グループは ui.lua に集約

group 名（プレフィックスのラベル）の登録は which-key の関心として ui.lua の `wk.add` に置く既存方針を踏襲し、`{ "<leader>f", group = "find" }` を1行足す。実キーマップは finder.lua、group 名は ui.lua、という hunks と同じ分離。which-key 不在でも `desc` は無害。

### D6: snacks の version は省略（default ブランチ）

snacks は純 Lua で build フック不要。`vim.pack.add` で `version` を省略し default ブランチを使う（既存の lualine/which-key/gitsigns/ibl と同じ扱い）。lockfile が revision を固定するため再現性は確保される。breaking change が問題化したら個別にピンを足す。

## Risks / Trade-offs

- [snacks が多機能で意図せず他モジュールが動く] → setup に有効化するモジュール（picker）だけを書き、他は列挙しない＝既定無効のまま。スコープ外モジュールが動いていないことを動作確認項目に入れる。
- [snacks.picker の API 名が現物と食い違う（`grep_word`/`recent`/`lsp_symbols` 等）] → 実装直前に現物 README / `:h snacks-picker` で API 名を確認してから書く。設定は finder.lua の1ファイルに隔離。
- [`<leader>fs`（lsp_symbols）が LSP 未アタッチのバッファで無反応] → picker 側が空表示になるだけで害はない。LSP ナビ既定は別途維持。
- [default ブランチ追従で将来 breaking change] → lockfile が revision を固定。更新は `<leader>pu` の確認バッファ経由なので壊れたら戻せる。必要なら個別ピン。
- [snacks 未導入・オフライン初回] → `pcall` 保護。setup 失敗時は finder 無しで起動継続、キーマップは押下時に握り潰し。

## Migration Plan

1. `plugins.lua` の `vim.pack.add` に `folke/snacks.nvim` を追加（`version` 省略）。
2. `lua/config/finder.lua` を作成（snacks setup で picker のみ有効化、`<leader>f` キーマップ10個を `desc` 付き・遅延参照で定義、全体 `pcall` 保護）。
3. `plugins.lua` 末尾の require 群に `require("config.finder")` を追記。
4. `ui.lua` の `wk.add` に `{ "<leader>f", group = "find" }` を追加。
5. `nvim` を起動 → snacks clone。`<leader>ff`/`<leader>fg` 等が開くこと、`<leader>f` グループ名が which-key に出ることを確認。
6. picker 以外のモジュール（dashboard 等）が動いていないこと、既存 UI/LSP/git 動作が不変なことを確認。
7. lockfile に snacks の revision が追記されたことを確認し `git add`。
8. `README.md` に finder の節を追記。
9. ロールバック: `plugins.lua` の snacks 行と require 1行を戻し、`finder.lua` 削除、`ui.lua` の group 1行を戻し、`vim.pack.del({ "snacks.nvim" })`、ロックファイルを `git checkout`。

## Open Questions

- なし（バックエンド選定・picker 単独有効化・capability 分割・キーマップ名前空間はユーザー確認および既存方針から確定済み。snacks.picker の正確な API 名は実装直前に現物確認）。
