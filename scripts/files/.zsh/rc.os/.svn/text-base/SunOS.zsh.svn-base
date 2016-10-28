# Alias
 
alias date-rfc822="date '+%a, %d %b %Y %X %z'"
source $HOME/.zsh/rc.os/common.zsh

PATH=$HOME/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/ccs/bin:/usr/sfw/bin:/usr/openwin/bin:/usr/local/bin:/usr/local/sbin

MANPATH=/usr/man

# pkgsrc
if [ -d /usr/pkg ]; then
	PATH=$PATH:/usr/pkg/bin:/usr/pkg/sbin
	MANPATH=$MANPATH:/usr/pkg/man
fi

# blastwave
if [ -d /opt/csw ]; then
	PATH=$PATH:/opt/csw/bin:/opt/csw/sbin
	MANPATH=$MANPATH:/opt/csw/man
fi

export PATH MANPATH

# Prompt 
autoload -U colors
colors

# Format
date_format="%H:%M"

date="%{$fg[$date_color]%}%D{$date_format}"

zonename=$(zonename)

if [[ $zonename == "global" ]]; then
	host="%{$fg[$user_color]%}%n%{$reset_color%}~%{$fg[$host_color]%}%m"
else
	host="%{$fg[$user_color]%}%n%{$reset_color%}~%{$fg[$host_color]%}%m:$zonename"
fi

cpath="%{$fg[$path_color]%}%/%b"
end="%{$reset_color%}"

PS1="$date$end ($host$end) $cpath
$end%% "

# Check for gnuls
if [[ -x $(which gls) ]] ; then
	eval `gdircolors $HOME/.zsh/misc/dircolors.rc`
	alias ls='gls --color'
	zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi

# 
[ -x $(which gtar) ] && alias tar=gtar

## I know it's bad, but.. solaris terminfo sux
if [[ $TERM == "screen" && ! -f /usr/share/lib/terminfo/s/screen ]]; then
	export TERM=vt100
fi 

if [[ -x $(which vim) ]]; then
	export EDITOR=vim
else
	export EDITOR=vi
fi

# Override TERM to VT100 before ssh if set to screen
ssh () {
   target=$_
   target=${target//*@/}
   set_title $target

	if [[ $TERM == "screen" ]] ; then
	   TERM=vt100 command ssh $*
	else
		command ssh $*
	fi
}

# Override ps output format
if [[ $(zonename) == "global" ]] ; then
	alias ps='ps -efZ'
fi
