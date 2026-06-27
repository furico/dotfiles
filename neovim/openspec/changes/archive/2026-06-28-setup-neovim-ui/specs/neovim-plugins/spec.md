## REMOVED Requirements

### Requirement: 検証用 colorscheme の起動時適用

**Reason**: `setup-neovim-plugins` で入れた検証用 colorscheme（tokyonight）は「差し替え可能な検証用 1 プラグイン」（plugins design D3）であり、vim.pack 土台が動くことの確認が目的だった。本 change で本命の colorscheme（catppuccin）へ移行し、配色の責務を UI レイヤ（`neovim-ui`）へ格上げするため、この暫定要件を削除する。

**Migration**: `neovim-ui` の「colorscheme（catppuccin）の適用」要件を参照。`plugins.lua` のインライン tokyonight 適用は削除し、`catppuccin` を `ui.lua` で setup・適用する。`vim.pack.add` レジストリからは tokyonight を外し catppuccin（`name="catppuccin"`）を足す。`neovim-plugins` の他要件（`vim.pack` による宣言的登録、ロックファイルの Git 管理、プラグイン管理キーマップ等）は変更しない。
