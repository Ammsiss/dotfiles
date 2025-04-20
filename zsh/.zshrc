# Init starship
eval "$(starship init zsh)"

# Brew path exports
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"

alias tree="eza --tree --icons"
alias ls='eza --icons'
alias cat='bat'
alias cl='clear'
alias mr='make && make run'

alias gc="git commit -m"
alias gs="git status"
alias gg="git pull"
alias gp="git push"

alias en='cd ~/dotfiles/nvim/.config/nvim/; nvim'

fd() {
    aerospace list-windows --all | fzf --bind 'enter:execute(bash -c "aerospace focus --window-id {2}")+abort'
}

doc() {
    if [[ "$1" =~ ^[1-9]$ ]]; then
        man "$1" "$2" | col -bx | nvim -c "setlocal buftype=nofile bufhidden=hide noswapfile | set filetype=man nomodifiable" -
    else
        man "$1" | col -bx | nvim -c "setlocal buftype=nofile bufhidden=hide noswapfile | set filetype=man" -
    fi
}

getid() {
    osascript -e "id of app \"$1\""
}

#########################################################################################
# Plugins
#########################################################################################

PLUG_DIR="$HOME/.local/share/zsh"

# Auto suggestion
if [ ! -d "$PLUG_DIR/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUG_DIR/zsh-autosuggestions"
fi
source "$PLUG_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Syntax Highlighting
if [ ! -d "$PLUG_DIR/syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUG_DIR/syntax-highlighting"
fi
source "$PLUG_DIR/syntax-highlighting/zsh-syntax-highlighting.zsh"
