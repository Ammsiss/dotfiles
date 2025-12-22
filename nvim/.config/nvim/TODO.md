### Bugs

#### Active
[] Figure out why I sometimes get errors from neoplug.

[] Handle 'no errors' error from Grep user command.

[] File tree git highlighting can be erroneous

[] Figure out why CTRL-O -> CTRL-I -> repeat, sometimes causes
  error "E19: Mark has invalid line number" (I found this
  doing it in man pages)

[] **Fedora August 2 immediately after launch:**
```bash
/home/ammsiss/.config/nvim/lua/config/neoplug.lua:135: attempt to index a nil value
stack traceback:
        /home/ammsiss/.config/nvim/lua/config/neoplug.lua:135: in function </home/ammsiss/.config/nvim/lua/config/neoplug.lua:133>
```

[] Handle 'no errors' error from Grep user command.

[] File tree git highlighting can be erroneous.

#### Completed

### Features
- Add tree view to *filetree.lua* and visual mode selection commands.
- Add max line limit and auto wrapping. (80 chars?)
- Clean up and minimilize neoplug.lua
- Add man page plugin/config
- Add a fuzzy find menu for man pages and nvim help ()
- Markdown stuff: Add a custom header renderer for markdown, add a way 
to auto indent bullet and numbered lists, as well as auto numbering 
(vim does have a way to do this), and also add a way to add word 
breaking with the '-' character so that paragraphs look more uniform.
- Figure out how to add treesitter parsing to inline markdown code 
blocks.
- Make a plugin for having a neovim buffer for command mode commands
