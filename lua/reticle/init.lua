local M = {}

require 'reticle.types'
--- @type reticle.opts_internal
local settings = nil -- This value is updated once the config is loaded
local conf = require('reticle.config')
local enabled = { cursorline = false, cursorcolumn = false }

-- Short aliases
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local contains = vim.tbl_contains
local create_cmd = vim.api.nvim_create_user_command

-- Wrapper function that sets an window local option. It translates the semantic
-- meaning of setting the cursorline to the actuall nvim api call.
local set_win_option = function(opt, enable, win)
    if opt == 'cursorline' and settings.always_highlight_number then
        vim.api.nvim_set_option_value('cursorlineopt', enable and 'both' or 'number', { win = win })
        vim.api.nvim_set_option_value('cursorline', true, { win = win })
    else
        vim.api.nvim_set_option_value(opt, enable, { win = win })
    end
end

-- Wrapper function that gets a nvim option. It considers the special case of
-- always highlighting the number column.
local get_option = function(name, opts)
    if name == 'cursorline' and settings.always_highlight_number then
        local clo = vim.api.nvim_get_option_value('cursorlineopt', opts)
        return clo == 'both'
    else
        return vim.api.nvim_get_option_value(name, opts)
    end
end

-- This function implements the logic whether and option is turned on or off on
-- window enter, depending on the filetype of the window and the user
-- configuration.
local on_enter = function(opt, win)
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = get_option('filetype', { buf = buf })
    local enable
    if contains(settings.ignore[opt], ft) then
        -- TODO: cursorlineopt should be set to 'both' when cursorline is
        -- enabled in trouble windows. Wait until PR is merged before this lines
        -- can be deleted.
        if ft == 'Trouble' and opt == 'cursorline' then
            vim.api.nvim_set_option_value('cursorlineopt', 'both', { win = win })
        end
        return
    elseif settings.disable_in_diff and get_option('diff', { win = win }) then
        enable = false
    elseif contains(settings.always[opt], ft) then
        enable = true
    elseif contains(settings.never[opt], ft) then
        enable = false
    elseif contains(settings.on_focus[opt], ft) then
        enable = true
    elseif settings.follow[opt] then
        enable = enabled[opt]
    end
    set_win_option(opt, enable, win)
end

-- This function implements the logic whether and option is turned on or off on
-- window leave, depending on the filetype of the window and the user
-- configuration.
local on_leave = function(opt, win)
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = get_option('filetype', { buf = buf })
    local enable
    if contains(settings.ignore[opt], ft) then
        return
    elseif settings.disable_in_diff and get_option('diff', { win = win }) then
        enable = false
    elseif contains(settings.always[opt], ft) then
        enable = true
    elseif contains(settings.never[opt], ft) then
        enable = false
    elseif contains(settings.on_focus[opt], ft) then
        enable = false
    elseif settings.follow[opt] then
        enable = false
    end
    set_win_option(opt, enable, win)
end

-- This wrapper function delays the on_enter() function in order to get the
-- correct filetype
local deferred_on_enter = function(opt, win)
    vim.schedule(function()
        -- Exit if window does not exist anymore after deferring
        if vim.fn.win_id2win(win) == 0 then return end
        on_enter(opt, win)
    end)
end

-- This wrapper function delays the on_leave() function in order to get the
-- correct filetype
local deferred_on_leave = function(opt, win)
    vim.schedule(function()
        -- Exit if window does not exist anymore after deferring
        if vim.fn.win_id2win(win) == 0 then return end
        on_leave(opt, win)
    end)
end

-- Initialize the cursorline / cursorcolumn on each window on startup.
local initialize_windows = function()
    local cur_win = vim.api.nvim_get_current_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if win == cur_win then
            on_enter('cursorline', win)
            on_enter('cursorcolumn', win)
        else
            on_leave('cursorline', win)
            on_leave('cursorcolumn', win)
        end
    end
end

local register_autocmds = function()
    local enter_events = { 'WinEnter', 'BufWinEnter' }
    local leave_events = { 'WinLeave' }
    if settings.disable_in_insert then
        table.insert(enter_events, 'InsertLeave')
        table.insert(leave_events, 'InsertEnter')
    end
    local group = augroup('Reticle', { clear = true })
    autocmd(enter_events, {
        callback = function()
            local win = vim.api.nvim_get_current_win()
            deferred_on_enter('cursorline', win)
            deferred_on_enter('cursorcolumn', win)
        end,
        group = group,
    })
    autocmd(leave_events, {
        callback = function()
            local win = vim.api.nvim_get_current_win()
            deferred_on_leave('cursorline', win)
            deferred_on_leave('cursorcolumn', win)
        end,
        group = group,
    })
    autocmd('VimEnter', {
        callback = function()
            -- We call the init function on VimEnter to guarantee that windows
            -- are already created, particularly when the plugin is loaded
            -- directly during Vim startup.
            vim.schedule(function()
                initialize_windows()
            end)
        end,
        group = group,
    })
end

local create_usercommands = function()
    create_cmd('ReticleToggleCursorline', function() M.toggle_cursorline() end, {})
    create_cmd('ReticleToggleCursorcolumn', function() M.toggle_cursorcolumn() end, {})
    create_cmd('ReticleToggleCursorcross', function() M.toggle_cursorcross() end, {})
end

---@param user_config? reticle.opts
M.setup = function(user_config)
    -- Parse config and init plugin state
    settings = conf.get_settings(user_config)
    enabled.cursorline = settings.on_startup.cursorline
    enabled.cursorcolumn = settings.on_startup.cursorcolumn
    register_autocmds()
    create_usercommands()
    -- We must call the init function again here, because the user might
    -- lazyload the plugin on the VeryLazy event (which is fired after
    -- VimEnter).
    initialize_windows()
end

-- UTILITY FUNCTIONS

--- Enables or disables the cursorline based on the provided boolean value.
---@param enable boolean
M.set_cursorline = function(enable)
    local win = vim.api.nvim_get_current_win()
    enabled.cursorline = enable
    set_win_option('cursorline', enabled.cursorline, win)
end

--- Toggle the cursorline
M.toggle_cursorline = function()
    local win = vim.api.nvim_get_current_win()
    enabled.cursorline = not get_option('cursorline', { win = win })
    set_win_option('cursorline', enabled.cursorline, win)
end

--- Checks if the cursor line is enabled.
---@return boolean: true if the cursorline is enabled, false otherwise.
M.has_cursorline = function()
    return enabled.cursorline
end

--- Enables or disables the cursorcolumn based on the provided boolean value.
--- @param enable boolean
M.set_cursorcolumn = function(enable)
    local win = vim.api.nvim_get_current_win()
    enabled.cursorcolumn = enable
    set_win_option('cursorcolumn', enabled.cursorcolumn, win)
end

--- Toggle the cursorcolumn
M.toggle_cursorcolumn = function()
    local win = vim.api.nvim_get_current_win()
    enabled.cursorcolumn = not get_option('cursorcolumn', { win = win })
    set_win_option('cursorcolumn', enabled.cursorcolumn, win)
end

--- Checks if the cursor column is enabled.
--- @return boolean: true if the cursorcolumn is enabled, false otherwise.
M.has_cursorcolumn = function()
    return enabled.cursorcolumn
end

--- Enables or disables the cursorcross based on the provided boolean value.
--- @param enable boolean
M.set_cursorcross = function(enable)
    M.set_cursorline(enable)
    M.set_cursorcolumn(enable)
end

--- Toggle the cursorcross
M.toggle_cursorcross = function()
    local win = vim.api.nvim_get_current_win()
    if get_option('cursorcolumn', { win = win }) then
        M.set_cursorcross(false)
    else
        M.set_cursorcross(true)
    end
end

--- Checks if the cursorcross is enabled.
--- @return boolean: true if the cursorcross is enabled, false otherwise.
M.has_cursorcross = function()
    return enabled.cursorline and enabled.cursorcolumn
end

return M
