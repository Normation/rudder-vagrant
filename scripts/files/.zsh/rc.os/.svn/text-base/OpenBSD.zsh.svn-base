# Alias

alias date-rfc822="date '+%a, %d %b %Y %X %z'"

source $HOME/.zsh/rc.os/prompt.zsh
source $HOME/.zsh/rc.os/common.zsh

# Check for GNULS
if [ -x $(which gls) ] ; then
      eval `gdircolors $HOME/.zsh/misc/dircolors.rc`
      alias ls='gls --color'
      zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi
