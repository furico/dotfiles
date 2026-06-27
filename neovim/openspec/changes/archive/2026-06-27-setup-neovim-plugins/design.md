## Context

`setup-neovim-options` / `-keymaps` / `-autocmds`（いずれも archive 済み）で plugin-free 層を締めた。本 change はプラグイン時代の入口。`neovim-autocmds` の design では次回を「lazy.nvim 導入」と書いていたが、Neovim 0.12 が組み込みパッケージマネージャ `vim.pack` を同梱したため、外部マネージャを入れずランタイム標準だけで完結させる方針へ切り替える。

環境は nvim 0.12.3。`vim.pack` の事実（実環境のヘルプ `:help vim.pack` で確認済み）:

- API は `vim.pack.add({specs}, {opts})` / `update` / `del` / `get`。Spec は `{ src, name?, version?, data? }`。`version` は branch / tag / commit か `vim.version.range()`。
- プラグインは **data standard-path** の `site/pack/core/opt/<name>` にインストールされ、`add` が `:packadd` 相当でランタイムに載せる。
- ロックファイルは **`$XDG_CONFIG_HOME/nvim/nvim-pack-lock.json`**（= `~/.config/nvim/` 直下）に生成される。`vim.pack` の最初の呼び出しでロックファイルと disk を整合させ、ロックファイルがあればその revision で一括インストールする。手編集は禁止。
- 更新は `vim.pack.update()` が別タブに確認バッファを開き、`:write` で確定 / `:quit` で破棄。
- 同一セッションで同じプラグインを二度 `add` しても最初の登録だけが効く（再評価に強い）。
- `vim.pack` は WARNING として「まだ experimental だが日常使用には十分安定」と明記されている。

stow 配置の事実（実環境で確認済み）: `~/.config/nvim` は repo の `neovim/.config/nvim` へ **folded された単一ディレクトリ symlink**。よって `~/.config/nvim/` 直下に作られるファイルは物理的に repo 内に落ちる。

## Goals / Non-Goals

**Goals:**
- 外部プラグインマネージャを入れず、`vim.pack` だけでインストール・更新・ピン留め・複数マシン再現を成立させる。
- `lua/config/plugins.lua` という中立な薄い宣言層を作り、`init.lua` ローダから読み込む。
- ロックファイルを Git 管理し、別マシンで初回起動時に同一 revision を再現できるようにする。
- 検証用 colorscheme を 1 つ入れ、「インストール → 起動時適用」を見た目で確認できる最小実装にする。
- 初回起動でネットワーク不通でも nvim が壊れない（colorscheme 適用失敗を握りつぶす）。

**Non-Goals:**
- LSP・補完・Treesitter・ファイラ・statusline 等の機能プラグイン（別 change）。
- `PackChanged` による build フックの本格運用（今回入れる colorscheme は build 不要）。
- which-key 等のキーマップ基盤や `<leader>` 名前空間の体系化（土台が立った後）。
- 遅延ロード（lazy-loading）最適化。`vim.pack` は宣言時ロードが基本で、起動が問題になる規模に達してから検討する。

## Decisions

### D1: lazy.nvim ではなく `vim.pack` を採用

ランタイム標準のため追加の bootstrap（lazy.nvim 自身を git clone する初期化コード）が不要で、依存が 0 になる。ロックファイルによる revision 固定と複数マシン再現も組み込みで持つ。トレードオフとして lazy.nvim が持つ宣言的な遅延ロード・依存解決・リッチな UI は手に入らないが、本リポジトリの規模では過剰。素の仕組みを理解した上で、必要になったら上に薄く積める。

代替案: lazy.nvim → 却下（依存と bootstrap を増やす）。`packer` / `mini.deps` → 却下（同上、かつ `vim.pack` で代替可能）。

### D2: 中立名 `config.plugins` と薄い宣言層

`init.lua` の予約コメント `require("config.lazy")` を `require("config.plugins")` に置換し、`options` / `keymaps` / `autocmds` の後に読み込む（leader は options.lua で設定済みのため順序問題なし）。モジュール名にマネージャ固有名（`pack` / `vimpack`）を付けないことで、将来別レイヤを足しても名前が嘘にならないようにする。`plugins.lua` は「`vim.pack.add` でプラグインを列挙し、直後に最小の初期化（colorscheme 適用）を行う」だけの薄い層に保つ。

短い src 記法のため小さなローカルヘルパ `local function gh(repo) return "https://github.com/" .. repo end` を置く。`git insteadOf`（`gh:` 短縮）方式は却下: その短縮形がそのままロックファイルに書かれ、別マシンでも同じ git 設定を要求して可搬性を損なうため。ヘルパ方式ならロックファイルには完全な https URL が残る。

### D3: 検証用 colorscheme は tokyonight.nvim、適用は pcall で保護

最小の「見える」実プラグインとして colorscheme を 1 つ入れる。`tokyonight.nvim`（folke 製）を採用: Lua ネイティブで build 不要、`termguicolors`（options.lua で有効化済み）と噛み合い、`vim.cmd.colorscheme("tokyonight")` 単体で適用できる。

`vim.pack.add` は初回起動時に同期 clone するが、ネットワーク不通だと disk に載らず colorscheme 適用が起動エラーになる。これを避けるため適用は `pcall(vim.cmd.colorscheme, "tokyonight")` で包み、失敗時は `vim.notify(..., WARN)` でデフォルトのまま続行する。

代替: catppuccin / gruvbox → どれも妥当。tokyonight を既定とし、design 上は「差し替え可能な検証用 1 プラグイン」と位置づける。

### D4: ロックファイルは folded symlink 経由で repo に落ち、Git で追跡する

ロックファイルは `~/.config/nvim/nvim-pack-lock.json` に生成されるが、`~/.config/nvim` が repo への folded symlink のため、実体は `neovim/.config/nvim/nvim-pack-lock.json`（repo 内）に書かれる。したがって特別な配線は不要で、生成後に `git add` して追跡するだけでよい。

`.stowrc` への ignore 追加は不要: このファイルは stow のリンク対象（パッケージのソース）ではなく、folded ディレクトリ内に nvim が生成する実ファイルにすぎない。`README.*` / `LICENSE.*` のような stow 組み込み除外とも無関係。手編集禁止（`vim.pack` が管理）である旨を README に明記する。

### D5: プラグイン本体は repo に含めない（ロックファイルで再現）

プラグイン実体は data standard-path の `site/pack/core/opt/` に入り、repo の管理外。別マシンでは「ロックファイルを pull → 初回 `vim.pack` 呼び出しでロックファイルの revision を一括インストール」で再現する。submodule 等で実体を抱え込まない。

### D6: 更新・確認のキーマップは `<leader>p` 名前空間、plugins.lua に co-locate

`neovim-keymaps` は「`<leader>` 系はプラグイン導入回で扱う」と先送りしていた。本 change がその回。プラグイン管理操作を `<leader>p`（plugins）配下に最小限置く:

- `<leader>pu` … `vim.pack.update()`（全更新、確認バッファ）
- `<leader>ps` … `vim.pack.update(nil, { offline = true })`（オフラインで現状を確認・一覧）

これらは `vim.pack` に依存するため `keymaps.lua`（plugin-free）ではなく `plugins.lua` に置き、capability を自己完結させる。`local map = vim.keymap.set` 別名と `desc` 付与という keymaps の記述スタイルを踏襲する。which-key 等の名前空間体系化は今回はしない。

### D7: 冪等性は vim.pack と vim.keymap.set の性質に委ねる

`autocmds` 回のような `clear=true` augroup は今回不要。`vim.pack.add` は同一セッションの二度目以降を無視し、`vim.keymap.set` は上書き、colorscheme 適用も冪等。`PackChanged` autocmd を今回は導入しない（build フック不要のため）ので、再ソースで壊れる箇所はない。

## Risks / Trade-offs

- [`vim.pack` が experimental で将来 API が変わりうる] → 薄い宣言層に隔離してあるため、変更が来ても `plugins.lua` の局所修正で吸収できる。Spec は「`vim.pack` を用いる」を MUST にしつつ、キーマップの正確なキー以外は実装詳細に寄せない。
- [初回起動でネットワーク不通だとプラグイン未インストール] → colorscheme 適用を pcall で保護し起動は継続。ユーザーは復旧後 `<leader>pu` または再起動で取得できる。
- [ロックファイルを Git 管理すると、更新のたびに diff が出る] → 想定どおりの挙動（revision 追跡が目的）。手編集せず `vim.pack.update` の確認バッファ経由でのみ変える運用を README に明記。
- [`<leader>p` 名前空間が将来のプラグイン群と衝突] → 今は update/status の 2 つだけ。which-key 導入時に体系を整理する前提で、最小に留める。
- [同期 clone で初回起動が一瞬待たされる] → プラグイン 1 個なので軽微。規模が増えたら遅延導入を別途検討（Non-Goal）。

## Migration Plan

1. `neovim/.config/nvim/lua/config/plugins.lua` を作成（`gh` ヘルパ、`vim.pack.add` で tokyonight 登録、pcall colorscheme 適用、`<leader>pu`/`<leader>ps`）。
2. `neovim/.config/nvim/init.lua` の `require("config.lazy")` 予約コメントを除去し、`require("config.plugins")` を `autocmds` の後に追加。
3. `nvim` を起動 → 初回 clone が走り tokyonight が適用されることを確認。`~/.config/nvim/nvim-pack-lock.json`（= repo 内）が生成されることを確認。
4. ロックファイルを `git add` して追跡対象にする。
5. `<leader>pu` / `<leader>ps` が確認バッファ／オフライン一覧を開くことを確認。
6. `neovim/README.md` の構成図・メモを更新（plugins.lua、ロックファイルの扱い、stow 反映）。
7. ロールバック: `plugins.lua` と `init.lua` の require 行を戻し、`vim.pack.del({ "tokyonight" })` で実体削除、ロックファイルを `git checkout` で戻す。

## Open Questions

- なし（マネージャ選定・モジュール名・ロックファイル配置・検証プラグイン・キーマップ名前空間はユーザー確認および実環境調査で確定済み）。
