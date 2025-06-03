# Created by newuser for 6.9
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUNNSTALL/bin:$PATH"

# no brew message export HOMEBREW_NO_ENV_HINTS=true

[ -f "/home/pjt727/.ghcup/env" ] && . "/home/pjt727/.ghcup/env" # ghcup-env

export PATH="$PATH:/home/pjt727/.local/bin:/home/pjt727/.cargo/bin/:/home/pjt727/.custom-scripts/:/home/pjt727/go/bin"
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUNNSTALL/bin:$PATH"

# nnn plugins
export NNN_PLUG="f:autojump;p:preview-tui"
export NNN_FIFO=/tmp/nnn.fifo

# secrets
source /home/pjt727/secrets.zsh

define_word() {
    curl "https://api.dictionaryapi.dev/api/v2/entries/en/$1" | jq '.[0].meanings[].definitions[].definition'
}
syn_word() {
    curl "https://api.dictionaryapi.dev/api/v2/entries/en/$1" | jq '.[0].meanings[].synonyms'
}

# alias and custom functions
alias def=define_word
alias pkgInfo="pacman -Qq | fzf --preview 'pacman -Qil {} | bat -fpl yml' --layout=reverse  --bind 'enter:execute(pacman -Qil {} | less)"
alias syn=syn_word
alias ll="ls -alF"
alias icat="kitten icat"
alias gf="git add . & git commit . -m FastCommit & git push"
alias cd="z"
alias cdi="zi"
alias zf="zoxide query"
alias python="python3"
alias bu="brightnessctl set 10%+"
alias bd="brightnessctl set 10%-"
alias cat="bat"
# custom keybinds
bindkey "^[[2;5C" forward-word
bindkey "^[[1;5D" backward-word
# this is a crutch as I get used to my keyboard
#this may make it a lot more annoying to work wihtout this keybind but whatever
bindkey "^V" send-break

## python environments
# Customize the Zsh prompt to include the virtual environment name
# checks to see if there is a venv in this dir or a parent one

python_venv() {
  MYVENV=./venv
  PARENT_VENV=../venv
  # when you cd into a folder that contains $MYVENV
  [[ -d $MYVENV ]] && source $MYVENV/bin/activate
  # when you cd into a folder that doesn't
  [[ ! -d $MYVENV && ! -d $PARENT_VENV ]] && deactivate > /dev/null 2>&1
  # [[ ! -d $MYVENV && ! -d $PARENT_VENV ]] && deactivate > /dev/null
}
# for the startup of a prompt
MYVENV=./venv
PARENT_VENV=../venv
[[ -d $MYVENV ]] && source $MYVENV/bin/activate
autoload -U add-zsh-hook
add-zsh-hook chpwd python_venv

# case independant completeion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
#
# increase history for ghost test
setopt SHARE_HISTORY
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# not too sure how I feel about this but is def sometimes nice
# can be a little distracting (maybe make it togglable)
# source zsh-autocomplete/zsh-autocomplete.plugin.zsh

eval $(thefuck --alias tf)

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
#
# bun completions
[ -s "/home/pjt727/.bun/_bun" ] && source "/home/pjt727/.bun/_bun"

NPM_PACKAGES="${HOME}/.npm-packages"

export PATH="$PATH:$NPM_PACKAGES/bin"

# Preserve MANPATH if you already defined it somewhere in your config.
# Otherwise, fall back to `manpath` so we can inherit from `/etc/manpath`.
export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"
