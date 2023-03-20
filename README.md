Neovim-Tmux Navigation
--------------------------------------------------------------------------------

The plugin is a rewrite of [Christoomey's Vim Tmux Navigator](https://github.com/christoomey/vim-tmux-navigator), with a few added
benefits:

- fully written in Lua, compatible with NeoVim 0.7.0 or higher
- takes advantage of Lua closures
- does not use global vim variables
- switch to the next window (numerically), whether it is a `neovim` split or a
  `tmux` pane

The plugin does not, however, have a "save on switch" feature as _Vim Tmux
Navigator_ has, and does not work with `tmate`. For such features or any other,
please open an issue or a pull request.

The plugin targets `neovim 0.7.0` (for the keymap and user commands features)
and more recent versions, and `tmux 3.2a` and more recent versions, although
some of the older `tmux` versions should work as well.

## Installation

To use the plugin, install it through a package manager, like [vim-plug](https://github.com/junegunn/vim-plug) or
[packer](https://github.com/wbthomason/packer.nvim):

```vim
" vim-plug
Plug 'alexghergh/nvim-tmux-navigation'
```

```vim
" packer
use { "alexghergh/nvim-tmux-navigation" }
```

## Configuration

Before using the plugin, a few configuration steps are needed. Navigation keys
need to be set up inside both `tmux` and `neovim`. Ideally, both should have the
same navigation keys, so the transition between windows becomes transparent (it
doesn't care if it's inside a vim process or not).

### Tmux

The `tmux` part basically needs to know whether it is inside a `vim` process,
and send the navigation keys through to it in that case. If it is not, then it
just switches panes.

You need the lines below in your `~/.tmux.conf`. This assumes that you want
to use `Ctrl` keybinds to switch between windows, however feel free to switch to
any other prefix (like `Alt`/`Meta`; for example `M-h`).

Careful though, having `Ctrl` as prefix means that you lose access to the "clear
screen" terminal feature, activated by `<Ctrl-l>` by default. You can either:
- remap the keys to something like `Alt + h/j/k/l` if your terminal supports it
(not all do), or
- add a different keybind to clear screen in `~/.tmux.conf`, for example
`bind C-l send-keys 'C-l'`; this allows you to do `<prefix> C-l` to clear screen.

```tmux
# Smart pane switching with awareness of Vim splits.
# See: https://github.com/christoomey/vim-tmux-navigator

# decide whether we're in a Vim process
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

After you configured `tmux`, it's time to configure `neovim` as well.

To configure the keybinds, do (in your `init.vim`):

```vim
nnoremap <silent> <C-h> <Cmd>NvimTmuxNavigateLeft<CR>
nnoremap <silent> <C-j> <Cmd>NvimTmuxNavigateDown<CR>
nnoremap <silent> <C-k> <Cmd>NvimTmuxNavigateUp<CR>
nnoremap <silent> <C-l> <Cmd>NvimTmuxNavigateRight<CR>
nnoremap <silent> <C-\> <Cmd>NvimTmuxNavigateLastActive<CR>
nnoremap <silent> <C-Space> <Cmd>NvimTmuxNavigateNext<CR>
```

For `init.lua`, you can either map the commands manually (probably using
`vim.keymap.set`), or you can keep on reading to find out how the plugin can do
it for you!

There are additional settings for the plugin, for example disable navigation
between `tmux` panes when the current pane is zoomed. To activate this option,
just tell the plugin about it (inside the `setup` function):

```lua
require'nvim-tmux-navigation'.setup {
    disable_when_zoomed = true -- defaults to false
}
```

Additionally, if using [packer](https://github.com/wbthomason/packer.nvim)
inside your `init.lua`, you can do everything at once:

```lua
use { 'alexghergh/nvim-tmux-navigation', config = function()

        local nvim_tmux_nav = require('nvim-tmux-navigation')

        nvim_tmux_nav.setup {
            disable_when_zoomed = true -- defaults to false
        }

        vim.keymap.set('n', "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
        vim.keymap.set('n', "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
        vim.keymap.set('n', "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
        vim.keymap.set('n', "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
        vim.keymap.set('n', "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
        vim.keymap.set('n', "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)

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
                last_active = "<C-\\>",
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

**!NOTE**: You need to call the setup function of the plugin at least once, even
if empty:

```lua
use { 'alexghergh/nvim-tmux-navigation', config = function()
        require'nvim-tmux-navigation'.setup()
    end
}
```

## Usage

If you went through the [Configuration](#configuration), then congrats! You
should have a working set up.

As a summary, the keybinds are (assuming `Ctrl`-prefixed):
- `Ctrl + h`: move left
- `Ctrl + j`: move down
- `Ctrl + k`: move up
- `Ctrl + l`: move right
- `Ctrl + \`: move to the last (previously active) pane
- `Ctrl + Space` move to the next pane (by pane number)

## Alternatives

As with everything that's great in life, there are a ton of alternatives to this
plugin. These are great projects, born from the same desire to improve user
experience within Tmux and Neovim. Go check them out and see if you like those
more:
- [Nvimux-Navigator](https://github.com/emilienlemaire/nvimux-navigator)
- [tmux.nvim](https://github.com/aserowy/tmux.nvim)
- [ttymux.nvim](https://github.com/illia-danko/ttymux.nvim)
- [Navigator.nvim](https://github.com/numToStr/Navigator.nvim/)

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
