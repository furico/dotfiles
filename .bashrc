echo "Loading ${HOME}/.bashrc ..."

export HISTSIZE=100000
export HISTFILESIZE=100000

# aliases
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
export LS_COLORS='di=01;36:ln=01;35:so=01;32:ex=01;32:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# # 参考
# # https://qiita.com/yoshi-yoshi/items/a0c76f660572652cd55c
if [ $UID -eq 0 ]; then
    PS1="\[\033[31m\]\u@\h\[\033[00m\]:\[\033[01m\]\w\[\033[00m\]\n\\$ "
else
    PS1="\[\033[36m\]\u@\h\[\033[00m\]:\[\033[01m\]\w\[\033[00m\]\n\\$ "
fi

# 参考
# https://qiita.com/tmsanrinsha/items/72cebab6cd448704e366
function peco-select-history() {
    local tac
    which gtac &> /dev/null && tac="gtac" || \
        which tac &> /dev/null && tac="tac" || \
        tac="tail -r"
    READLINE_LINE=$(HISTTIMEFORMAT= history | $tac | sed -e 's/^\s*[0-9]\+\s\+//' | awk '!a[$0]++' | peco --query "$READLINE_LINE")
    READLINE_POINT=${#READLINE_LINE}
}

if which peco &> /dev/null; then
    bind -x '"\C-r": peco-select-history'
fi
