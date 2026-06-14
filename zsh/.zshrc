autoload -U colors && colors

zmodload -i zsh/complist
autoload -Uz compinit && compinit

# Show dotfiles in completion
_comp_options+=(globdots)
# This allows indirect make targets to be completion items
zstyle ':completion:*:make:*:targets' call-command true
zstyle ':completion:*:*:make:*' tag-order 'targets' 
zstyle ':completion:*' menu select
setopt MENU_COMPLETE
bindkey -M menuselect '^M' .accept-line

export MANPAGER='nvim +Man!'
export PATH="$HOME/.local/bin:$PATH"

export EDITOR="$HOME/.local/bin/nvim"

alias cl='clear'
alias ls='lsd'
alias cat='bat'
alias gs='git status -s'
alias diff='delta'
alias make='bear --append -- make'

source ~/.lscolors.sh # stow lsd

################################################################
# Plugins
################################################################

PLUG_DIR="$HOME/.local/share/zsh"

# Auto suggestion
if [ ! -d "$PLUG_DIR/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUG_DIR/zsh-autosuggestions"
fi
source "$PLUG_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Syntax highlighting
if [ ! -d "$PLUG_DIR/syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUG_DIR/syntax-highlighting"
fi
source "$PLUG_DIR/syntax-highlighting/zsh-syntax-highlighting.zsh"

# Vim mode
if [ ! -d "$PLUG_DIR/zsh-vi-mode" ]; then
  git clone https://github.com/jeffreytse/zsh-vi-mode.git "$PLUG_DIR/zsh-vi-mode"
fi
source "$PLUG_DIR/zsh-vi-mode/zsh-vi-mode.zsh"
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
ZVM_VI_SURROUND_BINDKEY=s-prefix

# Prompt
setopt PROMPT_SUBST
git_dirty_marker() {
  git rev-parse --is-inside-work-tree &>/dev/null || { echo ' '; return; }
  [[ -n $(git status --porcelain 2>/dev/null) ]] && echo '%F{#b16286}+%f ' || echo ' '
}
PROMPT='%F{#4a858c}%1~%f$(git_dirty_marker)%F{#b57614}>%f '
