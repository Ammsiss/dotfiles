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
- Make a plugin that creates a nvim buffer that you can write a zsh 
command in that is half way between simple and script.
- Make a plugin that lets you just type a filename and it opens it 
without having to put the path in. It should only search directories 
you list in the settings of the plugin. If there are multiple files 
with the same name it should prompt you to pick what you want.

### Starship

- Stop using starship - configure your own prompt

### General

- Add config file for 'stat' command
- Add a better git manager. Start with something small like a more
dynamic diff view.
- Add custom man pages for make especially ref section in pinfo
