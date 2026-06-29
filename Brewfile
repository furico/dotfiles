# Brewfile — この dotfiles が依存する CLI ツールを一括導入する。
#
# 思想: ここに載せるのは「リポジトリ内の設定ファイルが実際に前提とするもの」だけ。
# 普段使いの無関係なツール（言語処理系・GUI アプリ等）は意図的に含めない。
# 各エントリには各設定ファイルと同じく「なぜ必要か」を残す。
#
# 使い方:
#   brew bundle install --file=~/dotfiles/Brewfile      # 一括インストール
#   brew bundle check   --file=~/dotfiles/Brewfile      # 不足を確認（変更なし）
#   brew bundle cleanup --file=~/dotfiles/Brewfile      # ※全環境基準で削除提案するため非推奨
#
# 注: この Brewfile はリポジトリ直下にあり、stow のパッケージ（各サブディレクトリ）
# ではないため symlink 対象にはならない。--file で明示的に指す。

# ── コア: エディタ / ターミナル多重化 ─────────────────────────────
brew "neovim"   # 主エディタ。~/.config/nvim/ 一式の前提。
brew "tmux"     # 「Neovim｜エージェント｜シェル」三者構成のペイン多重化。
brew "vim"      # フォールバックエディタ（vim/ パッケージの .vimrc）。
brew "stow"     # この dotfiles 自体の symlink 管理。

# ── 検索バックエンド（Neovim snacks picker / fzf / z）─────────────
brew "ripgrep"  # snacks picker の grep 実体。無くても起動はするが必須級。
brew "fd"       # snacks picker の files 実体（高速なファイル列挙）。
brew "fzf"      # zsh プラグイン（plugins=(... fzf)）の曖昧検索。

# ── Git まわり ───────────────────────────────────────────────────
brew "gh"        # GitHub CLI。
brew "ghq"       # リポジトリのクローン/管理。
brew "lazygit"   # tmux の prefix+C-g ポップアップから起動する TUI。
brew "git-delta" # git diff/show/log の差分を彩色する pager（git/.gitconfig が前提）。

# ── zsh 体験向上（zsh/.zshrc が source / init する前提）──────────
brew "starship"                # プロンプト。ZSH_THEME を無効化し starship が描画する。
brew "zsh-autosuggestions"     # 履歴からのゴースト補完（→ / C-e で確定）。
brew "zsh-syntax-highlighting" # 入力中のコマンド正誤を色分け。.zshrc 末尾で source。
brew "zoxide"                  # 賢い cd。oh-my-zsh の z プラグインを置き換える。
brew "eza"                     # ls の後継。ls/ll/la/lt エイリアスの実体。
brew "bat"                     # cat の後継（シンタックスハイライト）。cat エイリアスの実体。

# ── ビューア / 補助ユーティリティ ────────────────────────────────
brew "glow"            # Markdown を端末で閲覧。
brew "tree"            # ディレクトリ構造の確認。
brew "wget"            # 各種ダウンロード。
brew "tree-sitter-cli" # nvim-treesitter のパーサ生成/管理に使う CLI。

# ── GUI / フォント（cask）────────────────────────────────────────
cask "1password-cli"                  # シークレット取得（op）。
cask "font-jetbrains-mono-nerd-font"  # ghostty/nvim が使う Nerd Font。アイコン表示に必須。

# ── brew 管轄外（参考・手動セットアップが必要なもの）──────────────
# 以下は Homebrew では入らないため Brewfile に含めない。README 等で手順を案内する:
#   - ghostty   … 端末エミュレータ。手動インストール（cask 管理しない）。
#   - oh-my-zsh … zsh/.zshrc が前提（インストーラスクリプトで導入）。
#   - TPM       … tmux プラグイン管理。~/.local/share/tmux/plugins/tpm へ git clone。
#   - LSP サーバ … nvim 起動後に mason が ensure_installed で自動導入。
