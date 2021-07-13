local util = require'nvim-tmux-navigation.tmux_util'

local M = {}

-- default configuration, can be changed through the setup function
local config = {
    disable_when_zoomed = false
}

local function vim_navigate(direction)
    if pcall(vim.cmd, 'wincmd ' .. direction) then
        -- success
    else
        -- error, cannot wincmd from the command-line window
        vim.cmd([[ echohl ErrorMsg | echo 'E11: Invalid in command-line window; <CR> executes, CTRL-C quits' | echohl None ]])
    end
end

local function tmux_navigate(direction)
    -- whether tmux should control the previous pane switching or no
    --
    -- by default it's true, so when you enter a new vim instance and
    -- try to switch to a previous pane, tmux should take control
    local tmux_control = tmux_control or true

    if direction == 'p' then

        -- if the last pane was a tmux pane, then we need to handle control
        -- to tmux; otherwise, just issue a last pane command in vim
        if tmux_control == true then
            util.tmux_change_pane(direction)
        elseif tmux_control == false then
            vim_navigate(direction)
        end

    elseif direction ~= 'p' then

        -- save the current window number to check later whether we're in the same
        -- window after issuing a vim navigation command
        local winnr = vim.fn.winnr()
        
        -- try to navigate normally
        vim_navigate(direction)

        -- if we're in the same window after navigating
        local is_same_winnr = (winnr == vim.fn.winnr())

        -- if we're in the same window and zoom is not disabled, tmux should take control
        if util.should_tmux_control(is_same_winnr, config.disable_when_zoomed) then
            util.tmux_change_pane(direction)
            tmux_control = true
        else
            tmux_control = false
        end
    end
end

function M.setup(user_config)
    -- disable nvim tmux navigation when a tmux pane is zoomed
    -- defaults to false
    config.disable_when_zoomed = user_config.disable_when_zoomed or false
end

if vim.env.TMUX ~= nil then
-- if in tmux, map to vim-tmux navigation
    function M.NvimTmuxNavigateLeft() tmux_navigate('h') end
    function M.NvimTmuxNavigateDown() tmux_navigate('j') end
    function M.NvimTmuxNavigateUp() tmux_navigate('k') end
    function M.NvimTmuxNavigateRight() tmux_navigate('l') end
    function M.NvimTmuxNavigatePrevious() tmux_navigate('p') end
else
-- if not in tmux, simply map to normal vim navigation
    function M.NvimTmuxNavigateLeft() vim_navigate('h') end
    function M.NvimTmuxNavigateDown() vim_navigate('j') end
    function M.NvimTmuxNavigateUp() vim_navigate('k') end
    function M.NvimTmuxNavigateRight() vim_navigate('l') end
    function M.NvimTmuxNavigatePrevious() VimNavigate('p') end
end

return M
