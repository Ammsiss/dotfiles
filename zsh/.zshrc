PROMPT="%1~> "

# iterm shell integration
test -e /Users/ammsiss/.iterm2_shell_integration.zsh && source /Users/ammsiss/.iterm2_shell_integration.zsh || true

# garbag
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# Created by `pipx` on 2025-02-27 11:46:11
export PATH="$PATH:/Users/ammsiss/.local/bin"
export PATH="$HOME/.nvim-env/bin:$PATH"

# perl
PATH="/Users/ammsiss/.perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/ammsiss/.perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/ammsiss/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/ammsiss/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/ammsiss/perl5"; export PERL_MM_OPT;

# ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# better tree
alias tree="eza --tree --icons"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

alias en='cd ~/dotfiles/nvim/.config/nvim/; nvim'
alias nvcpp='nvim **/*.cpp **/*.h'

eval "$(starship init zsh)"

alias ls='eza --icons'
alias prj='cd ~/Projects'
export MANPATH="$HOME/.cppman:$MANPATH"
alias cat='bat'

alias nvim-dev='NVIM_APPNAME=nvim-dev nvim'
