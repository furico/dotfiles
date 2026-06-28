## MODIFIED Requirements

### Requirement: which-key とグループ登録

`which-key.nvim` を setup し、キー押下途中に割当てをポップアップ表示しなければならない（MUST）。`<leader>` 名前空間のグループ名（少なくとも `<leader>p`=plugins、`<leader>h`=hunks、`<leader>f`=find）に加え、`s`=surround のグループ名を登録する（MUST）。group 名は `ui.lua` の `wk.add` に集約し、各 capability の実キーマップ（hunks は git.lua、find は finder.lua、surround は mini.surround の `s*` 既定）とは分離する。既存マッピングの `desc` をそのまま説明として用い、`keymaps.lua` は plugin-free に保つ。

#### Scenario: ポップアップが出る

- **WHEN** `<leader>` を押して少し待つ
- **THEN** which-key のポップアップに、その配下のマッピングが `desc` 付きで一覧表示される

#### Scenario: グループ名が付く

- **WHEN** which-key のポップアップで `<leader>p` / `<leader>h` / `<leader>f` / `s` を確認する
- **THEN** それぞれ plugins / hunks / find / surround のグループ名が表示される
