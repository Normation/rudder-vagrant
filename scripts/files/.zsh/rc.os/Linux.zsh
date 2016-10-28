alias ls='ls --color'
alias grep='grep --color'

source $HOME/.zsh/rc.os/prompt.zsh
source $HOME/.zsh/rc.os/common.zsh

# Add name of (Debian) SCHROOT if exists

if [ -r /etc/debian_chroot ] ; then
	chrootname=${$(< /etc/debian_chroot)//-*}
	host="%{$fg[$user_color]%}%n:${chrootname}%{$reset_color%}~%{$fg[$host_color]%}%m"
else
	host="%{$fg[$user_color]%}%n%{$reset_color%}~%{$fg[$host_color]%}%m"
fi

# permit parameter expansion, command substitution and arithmetic expansion 
# in prompt
setopt prompt_subst

precmd () { 
	local buffer load
	load=(${$(< /proc/loadavg)})
	LOADAVG="$load[1] $load[2]"
	buffer=(${$(free)})
	MEM="$((100 * $buffer[16] / $buffer[8]))%%"
	if [[ $buffer[19] != 0 ]]; then
		MEM="$MEM $((100 * $buffer[20] / $buffer[19]))%%"
	fi
	if [ -d $PWD/.svn ] ; then
		PATHINFO="(svn):$PWD"
	else
		PATHINFO=$PWD
	fi
}

cpath="%B%{$fg[$path_color]%}\$PATHINFO%b"
end="%{$reset_color%}"
stats="%{$fg[$status_color]%}[\$LOADAVG - \$MEM]"
PS1="$date$end ($host$end) $cpath
$end%% "
RPS1="$stats%{$reset_color%}"

# function use to toggle RPS1 (which is very ugly for copy/paste)
function rmrps1 () {
	unset RPS1
}

function rps1 () {
	RPS1="$stats%{$reset_color%}"
}

# zstyle OS specific
eval `dircolors $HOME/.zsh/misc/dircolors.rc`

# Use LS_COLORS for color completion
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Distrib specific
[ -r /etc/debian_version ] && source $HOME/.zsh/rc.os/Debian.zsh
