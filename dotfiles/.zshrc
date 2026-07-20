export PATH=$HOME/.local/bin:$PATH

autoload -Uz compinit && compinit
compdef _gnu_generic -default-
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'

autoload -Uz select-word-style
select-word-style bash
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^H' backward-kill-word
bindkey '^[[3~' delete-char
bindkey '^[[3;5~' kill-word

source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

eval "$(starship init zsh)"
if [[ -o interactive ]]; then
    fastfetch
fi
