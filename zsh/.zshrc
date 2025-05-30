# Init starship
eval "$(starship init zsh)"

# Load autocomplete
autoload -Uz compinit
compinit
_comp_options+=(globdots)
setopt MENU_COMPLETE
zstyle ':completion:*' menu select

autoload -U colors
colors

# Brew path exports
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"
export MallocNanoZone=0

# Aliases
alias cl='command clear'
alias clear='echo "Use cl instead!"'

alias mr='make && make run'
alias en='cd ~/dotfiles/nvim/.config/nvim/; nvim'
alias openbitch='xattr -cr'

alias -g tree="lsd --tree"
alias -g ls='lsd'
alias -g cat='bat'

alias -g gs="command git status"
alias -g gpu="command git pull"
alias -g gp="command git push"
alias -g gc="command git commit"
alias -g gca="command git commit -a"

git() {
    if [[ "$1" == "commit" || "$1" == "status" || "$1" == "push" || "$1" == "pull" ]]; then
        echo "Use aliases"
    else
        command git "$@"
    fi
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

# Set up fzf key bindings and fuzzy completion
# source <(fzf --zsh)

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

# Enable VI mode
cursor_mode() {
    cursor_block='\e[2 q'
    cursor_beam='\e[6 q'

    function zle-keymap-select {
        if [[ ${KEYMAP} == vicmd ]] ||
            [[ $1 = 'block' ]]; then
            echo -ne $cursor_block
        elif [[ ${KEYMAP} == main ]] ||
            [[ ${KEYMAP} == viins ]] ||
            [[ ${KEYMAP} = '' ]] ||
            [[ $1 = 'beam' ]]; then
            echo -ne $cursor_beam
        fi
    }

    zle-line-init() {
        echo -ne $cursor_beam
    }

    zle -N zle-keymap-select
    zle -N zle-line-init
}

cursor_mode

# Check available widgets: zle -la
# Check whats bound: bindkey -M viins '^U'
bindkey -v
export KEYTIMEOUT=3
# Rebind useful stuff
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char
bindkey -M viins '^E' autosuggest-accept
bindkey -M viins '^U' backward-kill-line
bindkey -M viins '^B' end-of-line
bindkey -M viins '^A' beginning-of-line
