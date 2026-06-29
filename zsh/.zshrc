# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# プロンプトは starship が描画するため oh-my-zsh のテーマは無効化する（空文字）。
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# z は zoxide に置き換えたため外す（zoxide は .zshrc 下部で init する）。
plugins=(git fzf)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# XON/XOFF フロー制御を無効化。C-s（出力停止）と C-q（再開）を解放する。
# tmux 内では tmux が C-q を prefix として奪うため本設定は不要だが、
# tmux 外のシェルで C-q を使いたい場合（readline の quoted-insert など）に必要。
stty -ixon

# ── Homebrew 製 zsh ツールの読み込み ──────────────────────────────────────
# Brewfile で導入したものを source / init する。brew --prefix は起動のたびに呼ぶと
# 遅いため 1 回だけ評価してキャッシュ。各読み込みは未インストールでも壊れないよう
# 存在確認する。
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"

  # 履歴からのゴースト補完（→ / C-e で確定）。
  [ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
    && source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# ── 履歴設定 ──────────────────────────────────────────────────────────────
# 履歴を十分に確保し、重複を除去、複数シェル間で共有する。
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY        # セッション間で履歴を即共有する
setopt HIST_IGNORE_ALL_DUPS # 重複コマンドは古い方を捨てる
setopt HIST_IGNORE_SPACE    # 先頭スペース付きコマンドは記録しない
setopt HIST_REDUCE_BLANKS   # 余分な空白を圧縮して記録する

# ── zoxide（賢い cd。z プラグインの後継）──────────────────────────────────
# z <部分一致> でジャンプ、zi で fzf 対話選択。
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# ── starship プロンプト ───────────────────────────────────────────────────
# 設定は ~/.config/starship.toml（starship パッケージを stow で配置）。
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# ── モダン CLI のエイリアス ───────────────────────────────────────────────
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias ll='eza -l --git --group-directories-first'
  alias la='eza -la --git --group-directories-first'
  alias lt='eza --tree --level=2'
fi
command -v bat >/dev/null 2>&1 && alias cat='bat'

# Machine-specific settings (not tracked in dotfiles)
[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"

# ── zsh-syntax-highlighting（必ず最後に読み込む）──────────────────────────
# 行編集に関わる他の設定（補完・widget 等）をすべて読み込んだ後でないと正しく
# 動かないため、.zshrc.local も含めた最終行に置く。
[ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] \
  && source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
