# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions fasd ssh-agent zsh-syntax-highlighting)

# see https://github.com/junegunn/fzf/issues/3703#issuecomment-2675484142
# this will be working with ubuntu 26 
if command -v fzf &>/dev/null; then
  # Don't source FZF shell integrations if version is older than 0.48 (Avoids `unknown option: --bash`)
  # Version comparison technique courtesy of Luciano Andress Martini:
  # https://unix.stackexchange.com/questions/285924/how-to-compare-a-programs-version-in-a-shell-script
  FZF_VERSION="$(fzf --version | cut -d' ' -f1)"
  if [[ -f ~/.fzf.zsh && "$(printf '%s\n' 0.48 "$FZF_VERSION" | sort -V | head -n1)" = 0.48 ]]; then
    source $HOME/.fzf.zsh
  fi
fi

[[ -f $ZSH/oh-my-zsh.sh ]] && source $ZSH/oh-my-zsh.sh
[[ -f $HOME/.p10k.zsh ]] && source $HOME/.p10k.zsh

bindkey '^I' complete-word  # Make tab do completion
bindkey '^[[Z' autosuggest-accept  # Shift-Tab to accept autosuggestion

# see https://github.com/romkatv/powerlevel10k/issues/1554#issuecomment-1700907172
unset ZSH_AUTOSUGGEST_USE_ASYNC  # Disable async suggestions for performance

FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

export PATH="$HOME/scripts:$PATH"

zstyle :omz:plugins:ssh-agent agent-forwarding yes
zstyle :omz:plugins:ssh-agent quiet yes
zstyle :omz:plugins:ssh-agent lazy yes