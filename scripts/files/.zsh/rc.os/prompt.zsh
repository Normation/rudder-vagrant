# Prompt 
autoload -U colors
colors

# Format
date_format="%H:%M"

date="%{$fg[$date_color]%}%D{$date_format}"

host="%{$fg[$user_color]%}%n%{$reset_color%}~%{$fg[$host_color]%}%m"

cpath="%{$fg[$path_color]%}%/%b"
end="%{$reset_color%}"

PS1="$date$end ($host$end) $cpath
$end%% "

