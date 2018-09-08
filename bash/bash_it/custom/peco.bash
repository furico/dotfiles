# 参考
# https://qiita.com/comuttun/items/f54e755f22508a6c7d78
peco-select-history() {
    declare l=$(HISTTIMEFORMAT= history | sort -k1,1nr | perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\s*//; $in=$_; if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' | peco --query "$READLINE_LINE")
    READLINE_LINE="$l"
    READLINE_POINT=${#l}
}
if which peco &> /dev/null; then
    bind -x '"\C-r": peco-select-history'
fi
