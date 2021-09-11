Neovim-Tmux Navigation
--------------------------------------------------------------------------------

The plugin is a rewrite of [Christoomey's Vim Tmux Navigator](https://github.com/christoomey/vim-tmux-navigator), with a few added
benefits:

- fully written in Lua, compatible with NeoVim 0.5.0 or higher
- doesn't use autocommands (which are not supported natively through the Lua api
in neovim 0.5.0), but instead takes advantage of Lua closures
- does not use global vim variables

The plugin does not, however, have a "save on switch" feature as
_Vim Tmux Navigator_ has, and does not work with `tmate`. For such features or any
other, please open an issue or a pull request.

The plugin was tested with `neovim 0.5.0` and `tmux 3.2a`, however I see no reason
why older `tmux` executables would not work.

## Installation

To use the plugin, install it through a package manager, like [vim-plug](https://github.com/junegunn/vim-plug) or
[packer](https://github.com/wbthomason/packer.nvim) (put the lines below in your `init.vim` file):

```vim
" vim-plug
Plug 'alexghergh/nvim-tmux-navigation'
```

```vim
" packer
use { "alexghergh/nvim-tmux-navigation" }
```

## Usage

The default keybinds are (in tmux):
- `Ctrl + h`: move left
- `Ctrl + j`: move down
- `Ctrl + k`: move up
- `Ctrl + l`: move right
- `Ctrl + \`: move to previous pane
- `Ctrl + Space` move to the next pane

However, this means that you lose access to the "clear screen" terminal feature,
activated by `<Ctrl-l>` by default. You can either:
- remap the keys to something like `Alt + h/j/k/l` if your terminal supports it
(not all do), or
- add a different keybind to clear screen in `~/.tmux.conf`, for example
`bind C-l send-keys 'C-l'`; this allows you to do `<prefix> C-l` to clear screen.

The keybinds can be changed in both neovim and tmux, see [configuration](#configuration).

## Configuration

### Tmux

To use the plugin, you need the following lines in your `~/.tmux.conf`:

```tmux
# Smart pane switching with awareness of Vim splits.
# See: https://github.com/christoomey/vim-tmux-navigator
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'
tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
    "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
    "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"
bind-key -n 'C-Space' if-shell "$is_vim" 'send-keys C-Space' 'select-pane -t:.+'

bind-key -T copy-mode-vi 'C-h' select-pane -L
bind-key -T copy-mode-vi 'C-j' select-pane -D
bind-key -T copy-mode-vi 'C-k' select-pane -U
bind-key -T copy-mode-vi 'C-l' select-pane -R
bind-key -T copy-mode-vi 'C-\' select-pane -l
bind-key -T copy-mode-vi 'C-Space' select-pane -t:.+
```

### Neovim

After you installed the plugin through a package manager, you need to add your
keybindings. The plugin does not assume any defaults, instead it lets the user
choose what their keybinds are (make sure these keybinds match the keybinds in
`~/.tmux.conf`, otherwise switching might not be so easy).

To configure the keybinds, do (in your `init.vim`):

```vim
nnoremap <silent> <C-h> :lua require'nvim-tmux-navigation'.NvimTmuxNavigateLeft()<cr>
nnoremap <silent> <C-j> :lua require'nvim-tmux-navigation'.NvimTmuxNavigateDown()<cr>
nnoremap <silent> <C-k> :lua require'nvim-tmux-navigation'.NvimTmuxNavigateUp()<cr>
nnoremap <silent> <C-l> :lua require'nvim-tmux-navigation'.NvimTmuxNavigateRight()<cr>
nnoremap <silent> <C-\> :lua require'nvim-tmux-navigation'.NvimTmuxNavigatePrevious()<cr>
nnoremap <silent> <C-Space> :lua require'nvim-tmux-navigation'.NvimTmuxNavigateNext()<cr>
```

There are additional settings for the plugin, for example disable navigation
between tmux panes when the current pane is zoomed. To activate this option,
just tell the plugin about it (put this in your `init.vim`, inside Lua heredocs):

```vim
lua <<EOF
require'nvim-tmux-navigation'.setup {
    disable_when_zoomed = true -- defaults to false
}
EOF
```

Additionally, if using [packer](https://github.com/wbthomason/packer.nvim), you can do:

```lua
use { 'alexghergh/nvim-tmux-navigation', config = function()
        require'nvim-tmux-navigation'.setup {
            disable_when_zoomed = true -- defaults to false
        }

        vim.api.nvim_set_keymap('n', "<C-h>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateLeft()<cr>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', "<C-j>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateDown()<cr>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', "<C-k>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateUp()<cr>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', "<C-l>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateRight()<cr>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', "<C-\>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigatePrevious()<cr>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', "<C-Space>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateNext()<cr>", { noremap = true, silent = true })
    end
}
```

Or, for a shorter syntax:

```lua
use { 'alexghergh/nvim-tmux-navigation', config = function()
        require'nvim-tmux-navigation'.setup {
            disable_when_zoomed = true, -- defaults to false
            keybindings = {
                left = "<C-h>",
                down = "<C-j>",
                up = "<C-k>",
                right = "<C-l>",
                previous = "<C-\>",
                next = "<C-Space>",
            }
        }
    end
}
```

The 2 snippets above are completely equivalent, however the first one gives you
more room to play with (for example to call the functions in a different
mapping, or if some condition is met, or to ignore `silent` in the keymappings,
or to additionally call the functions in visual mode as well, etc.).

## Additional help

For common issues, see [Vim-tmux navigator](https://github.com/christoomey/vim-tmux-navigator).

For other issues, feature-requests or problems, please open an issue on [github](https://github.com/alexghergh/nvim-tmux-navigation).

## Author

Alexandru Gherghescu (alexghergh@gmail.com)

With great thanks to [Chris Toomey](https://github.com/christoomey), whose plugin I used for a long time
before Neovim 0.5.0.

## License

The project is licensed under the MIT license. See [LICENSE](https://github.com/alexghergh/nvim-tmux-navigation/blob/master/LICENSE) for more
information.
