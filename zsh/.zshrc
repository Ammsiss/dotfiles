# Init starship
eval "$(starship init zsh)"

# Load autocomplete
autoload -Uz bashcompinit && bashcompinit

autoload -Uz compinit && compinit
_comp_options+=(globdots) # enable dot files
setopt MENU_COMPLETE
zstyle ':completion:*' menu select

# This makes zsh actually evaluate target rules for autocompletion
# with make. So $(EXE) expands dynamically.
zstyle ':completion:*:make:*:targets' call-command true
# This gives targets priority in the auto complete over variables
# and shit
zstyle ':completion:*:*:make:*' tag-order 'targets' 

autoload -U colors
colors

# Path exports
# TODO: move to ~/.zprofile ?

export FZF_DEFAULT_OPTS="
    --color=pointer:#E67E22,prompt:#E67E22
    --prompt='> ' 
    --layout=reverse 
    --preview 'bat --style=changes --color=always {}'
    --preview-window=right:70%:wrap:noinfo
    --bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down
"

# MacOS
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"
export MallocNanoZone=0

export MANPAGER='nvim +Man!'

# Fedora
export PATH="$HOME/.local/bin:$PATH"
alias gd="git status --porcelain | awk '{ print substr($0, 4) }' | fzf | xargs git diff"

cca() {
    echo -n "$1" | hexdump -c
}

# for portability always include the colon.
alias ctime='TZ=":Canada/Pacific" ./show_time'

# Aliases
alias cl='clear'
alias grep='rg'
alias mr='make && make run'
alias openbitch='xattr -cr'
alias tree='lsd --tree'
alias ls='lsd'
alias cat='bat'
alias g='git'
alias gs='git status -s'
alias fd='rg --files --hidden | fzf --multi | xargs -r nvim'
alias en='rg --hidden --files ~/dotfiles | fzf --multi | xargs -r nvim'
alias eo='rg --hidden --files ~/Nexus | fzf --multi | xargs -r nvim'
alias pp='~/.pull_script.sh'

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

zmodload -i zsh/complist
# 3. Bind Enter in menu-selection mode to accept the completion and execute:
bindkey -M menuselect '^M' .accept-line
