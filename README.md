# dotfiles

GNU Stow を使ってアプリごとの設定ファイルを管理するリポジトリ。

## ディレクトリ構造

アプリ名をトップレベルのディレクトリ（パッケージ）として、その中にホームディレクトリと同じパスで設定ファイルを配置する。

```
dotfiles/
├── vim/
│   └── .vimrc        # → ~/.vimrc
└── zsh/              # (例)
    └── .zshrc        # → ~/.zshrc
```

`stow <package>` を実行するとシンボリックリンクがホームディレクトリに作成される。

## Prerequisites

[Homebrew](https://brew.sh/) が必要。`stow` を含む CLI ツールは後述の `Brewfile` で一括導入する。

## セットアップ

新しいマシンでの再現手順。

```sh
# 1. リポジトリを取得
git clone https://github.com/furico/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. 依存 CLI ツールを一括インストール（stow 含む）
brew bundle install --file=~/dotfiles/Brewfile

# 3. 管理したいパッケージを個別に stow する
stow zsh neovim tmux vim ghostty git starship
```

### Brewfile

リポジトリ直下の `Brewfile` に、この dotfiles が依存する CLI ツールだけを厳選して記載している（無関係なツールは含めない）。stow のパッケージではないため symlink されず、`--file` で明示的に指す。

```sh
brew bundle install --file=~/dotfiles/Brewfile   # 一括インストール
brew bundle check   --file=~/dotfiles/Brewfile   # 不足の確認（変更なし）
```

### Homebrew 管轄外のセットアップ

`Brewfile` では入らないもの。stow 後に手動で実施する。

```sh
# oh-my-zsh（zsh/.zshrc が前提）
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# TPM（tmux プラグイン管理）。clone 後、tmux 内で prefix + I を実行して取得する
git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm

# git ユーザー識別情報（email/name はリポジトリに含めない）。コピー後に自分の値を記入する。
# email は GitHub の noreply アドレス推奨（実メールを公開せずコミットを帰属できる）。
cp ~/dotfiles/git/.gitconfig.local.example ~/.gitconfig.local
```

- **ghostty** … 端末エミュレータ。手動インストール（cask 管理しない）。
- **LSP サーバ** … Neovim 初回起動時に mason が自動導入する。

## 管理中のパッケージ

| パッケージ | 対象ファイル |
| --- | --- |
| `zsh` | `~/.zshrc` |
| `neovim` | `~/.config/nvim/` |
| `tmux` | `~/.config/tmux/` |
| `vim` | `~/.vimrc` |
| `ghostty` | `~/.config/ghostty/config` |
| `git` | `~/.gitconfig`（+ マシン固有の `~/.gitconfig.local`） |
| `starship` | `~/.config/starship.toml` |

## 新しいアプリを追加する

1. アプリ名のディレクトリを作成する
2. ホームディレクトリからの相対パスで設定ファイルを配置する
3. `stow <package>` でシンボリックリンクを作成する

```sh
mkdir -p ~/dotfiles/zsh
mv ~/.zshrc ~/dotfiles/zsh/.zshrc
cd ~/dotfiles
stow zsh
```

## パッケージを削除する

```sh
stow -D vim   # ~/.vimrc のシンボリックリンクを削除
```
