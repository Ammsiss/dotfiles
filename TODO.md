### Urgent

- Figure out why all the .git exes are in the dap configs list
- Make <C-d> scroll git changes fzf-lua preview
- fzf-lua should not show exes and respect .gitignore

### DAP

- [ ] Create a callback trigger on enter of a dap session so
  that you can have easier to type binds.
- [ ] Set up a external termianl for program printing to stdout.

### filetree.nvim

- [ ] Make file tree still a column but a floating window
  instead, then make opening a file track the buf you came from
- [ ] Make it so that when you close file tree it saves its
  position so when you reopen it is at that dir. Then you can
  also add a bind to go back to main cwd of nvim
- [ ] Add setup function for options
- [ ] Add gitignore parsing
- [ ] Update how the split is created so that it does not modify
  the current split layout; similar to the sidebar widget in dap
- [ ] **Add tree view** to *filetree.lua* and visual mode selection
  commands.
- [ ] Add file extension specific open commands for pdf's and
  images in *filetree.lua* and *fzf.lua*
- [ ] Add dir sym link support. This will involve removing all
  of the harded coded icon look ups for directory binds.
- [ ] Support LS_COLORS variable to define highlights

### fzf.lua

- [ ] Add devicons to the display list
- [ ] Use `--multi` with the git status picker and let selections be
  automatically added to the next commit with `git add`.
- [ ] previewers for man pages and neovim help.

### nvim-cmp

- [ ] Go through highlighting on the man page
- [ ] look into other completion methods
- [ ] Look into bug when completion window is larger then screen
  width

### markdown.lua

- [ ] In *markdown.lua* Add auto placeing of comment leader, and '-'
  placement on textwidth limit violation for more uniform lines.
- [ ] In *markdown.lua* add rendering for *pipe tables*
- [ ] Add rendering for latex. The markdown-inline parser
  already can auto detect latex so its just a matter of querying
  the markdown-inline parser.
- [ ] Use parser:register_cbs, this is a callback so you don't
  have to clear and read marks everytime insert mode changes
  just when the tree changes. Also add a debounce after each
  callback so that multiple quick edits don't all reset
  everything. You could use `vim.uv.new_timer()` per buffer on
  each TextChanged, stop/start timer; on fire, schedule refresh

### Random

- [ ] Retire neoplug :( its builtin now
- [ ] Create a TODO list manager
- [ ] Create a scratch pad bind for man pages. This will unify
  documentation and personal notes/gotchas.
- [ ] Zsh neovim command buffer. Make a plugin that creates a
  nvim buffer that you can write a zsh command in that is half
  way between simple and script.
- [ ] go through opts.lua for any settings that should be
  opt_local.
- [ ] can the shell invocation of neovim man plugin do syntax
  highlighting for c code?
- [ ] Make a utility to make setting LS_COLORS easier

## ZSH

- [ ] Make the .zshrc check for updates for plugins
- [ ] Add environment variable that stores c/c++ build flags.
- [ ] Learn more about zle line editor with the goal of syncing the
  vim line editor mode with the system clipboard. Also figure out
  why sometimes it takes multiple times to leave normal mode.
- [ ] Figure out how to get dev-icon highlighting for ls/lsd
- [ ] Stop using starship. configure your own prompt. Don't
  necessarily have to have all the bells ans whistles but it
  would be nice to still have some git information.
