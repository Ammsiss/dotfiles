# See this for wezterms default login shell spawning behaviour
# https://github.com/wezterm/wezterm/discussions/4544
#
# This script is sourced when a login shell is started by 'zsh -l'.
#
# Wezterm always launches new shells (tabs or windows) as login
# shells in order to ensure consistency with ssh sessions or mux
# sessions

echo "Hello this is a login shell"
