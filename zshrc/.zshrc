# Created by newuser for 5.9

# no brew message
export HOMEBREW_NO_ENV_HINTS=true

export PATH="$PATH"
source /home/pjt727/secrets.zsh

# alias and custom functions
alias ll="ls -alF"
alias cd="z"
alias cdi="zi"
alias python="python3"
# custom keybinds
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

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

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
