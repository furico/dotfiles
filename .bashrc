echo "Loading ${HOME}/.bashrc ..."

export HISTSIZE=100000
export HISTFILESIZE=100000

# 参考
# https://qiita.com/yoshi-yoshi/items/a0c76f660572652cd55c
alias ls='ls -FG'
alias ll='ls -alFG'
alias rm='rm -i'
if [ $UID -eq 0 ]; then
    PS1="\[\033[31m\]\u@\h\[\033[00m\]:\[\033[01m\]\w\[\033[00m\]\\$ "
else
    PS1="\[\033[36m\]\u@\h\[\033[00m\]:\[\033[01m\]\w\[\033[00m\]\\$ "
fi


case ${OSTYPE} in
    darwin*)
        export CLICOLOR=1
        export LSCOLORS=gxfxcxdxcxegedabagacad
    ;;
esac
