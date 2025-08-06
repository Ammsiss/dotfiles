### ZSH

- Add environment variable that stores c/c++ build flags.
- Figure out how to synchronize vim mode clipboard with wez
  term copy mode and system clipboard
- Figure out why vim mode requires esc multiple times sometimes
- Replace builtin visual vim mode with wez term copy mode. To
  do this probably need to make zsh and wezterm interact through
  a function from wezterm revealing current vim mode then dynamically
  apply copy mode from zsh based on that. See Shell Integration
  section of the wezterm manual.
- Play around with wezterm multiplexing server

### Starship

- Stop using starship - configure your own prompt
