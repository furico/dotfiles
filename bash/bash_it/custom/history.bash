export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=ignoredups
function share_history {
    history -a
    history -c
    history -r
}
safe_append_prompt_command share_history
# これがあると上手くいかない…
#shopt -u histappend
