# Init starship
eval "$(starship init zsh)"

# Brew path exports
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"

alias tree="eza --tree --icons"
alias ls='eza --icons'
alias cat='bat'

alias en='cd ~/dotfiles/nvim/.config/nvim/; nvim'

fd() {
    aerospace list-windows --all | fzf --bind 'enter:execute(bash -c "aerospace focus --window-id {2}")+abort'
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
