local M = {}

require 'reticle.types'
local conf = require('reticle.config')
local settings = nil -- This value is updated once the config is loaded
local enabled = { cursorline = false, cursorcolumn = false }

-- Short aliases
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local contains = vim.tbl_contains
local set_option = vim.api.nvim_win_set_option
local create_cmd = vim.api.nvim_create_user_command

-- This function translates the semantic meaning of changing a window local
-- option to the actual vim command.
local change_option = function(window, opt, enable)
    if opt == 'cursorline' and settings.always_highlight_number then
        set_option(window, 'cursorlineopt', enable and 'both' or 'number')
        set_option(window, 'cursorline', true)
    else
        set_option(window, opt, enable)
    end
end

-- This function implements the logic whether and option is turned on or off on
-- window enter, depending on the filetype of the window and the user
-- configuration.
local on_enter = function(opt, window)
    local buffer = vim.api.nvim_win_get_buf(window)
    local ft = vim.api.nvim_buf_get_option(buffer, 'filetype')
    if contains(settings.ignore[opt], ft) then
        return
    elseif contains(settings.never[opt], ft) then
        change_option(window, opt, false)
    elseif contains(settings.on_focus[opt], ft) or
        contains(settings.always[opt], ft) then
        change_option(window, opt, true)
    elseif settings.follow[opt] then
        change_option(window, opt, enabled[opt])
    end
end

-- This function implements the logic whether and option is turned on or off on
-- window leave, depending on the filetype of the window and the user
-- configuration.
local on_leave = function(opt, window)
    local buffer = vim.api.nvim_win_get_buf(window)
    local ft = vim.api.nvim_buf_get_option(buffer, 'filetype')
    if contains(settings.ignore[opt], ft) then
        return
    elseif contains(settings.always[opt], ft) then
        change_option(window, opt, true)
    elseif contains(settings.never[opt], ft) or
        contains(settings.on_focus[opt], ft) or
        settings.follow[opt] then
        change_option(window, opt, false)
    end
end

-- This wrapper function delays the on_enter() function in order to get the
-- correct filetype
local deferred_on_enter = function(opt, window)
    vim.schedule(function()
        -- Exit if window does not exist anymore after deferring
        if vim.fn.win_id2win(window) == 0 then return end
        on_enter(opt, window)
    end)
end

-- This wrapper function delays the on_leave() function in order to get the
-- correct filetype
local deferred_on_leave = function(opt, window)
    vim.schedule(function()
        -- Exit if window does not exist anymore after deferring
        if vim.fn.win_id2win(window) == 0 then return end
        on_leave(opt, window)
    end)
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
            local window = vim.api.nvim_get_current_win()
            deferred_on_enter('cursorline', window)
            deferred_on_enter('cursorcolumn', window)
        end,
        group = group,
    })
    autocmd(leave_events, {
        callback = function()
            local window = vim.api.nvim_get_current_win()
            deferred_on_leave('cursorline', window)
            deferred_on_leave('cursorcolumn', window)
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
    register_autocmds()
    create_usercommands()
    enabled.cursorline = settings.on_startup.cursorline
    enabled.cursorcolumn = settings.on_startup.cursorcolumn
    -- Show cursorline and/or cursorcolumn on startup
    local window = vim.api.nvim_get_current_win()
    on_enter('cursorline', window)
    on_enter('cursorcolumn', window)
end

-- UTILITY FUNCTIONS

M.enable_cursorline = function()
    local window = vim.api.nvim_get_current_win()
    enabled.cursorline = true
    on_enter('cursorline', window)
end

M.disable_cursorline = function()
    local window = vim.api.nvim_get_current_win()
    enabled.cursorline = false
    on_enter('cursorline', window)
end

M.toggle_cursorline = function()
    local window = vim.api.nvim_get_current_win()
    enabled.cursorline = not enabled.cursorline
    on_enter('cursorline', window)
end

M.has_cursorline = function()
    return enabled.cursorline
end

M.enable_cursorcolumn = function()
    local window = vim.api.nvim_get_current_win()
    enabled.cursorcolumn = true
    on_enter('cursorcolumn', window)
end

M.disable_cursorcolumn = function()
    local window = vim.api.nvim_get_current_win()
    enabled.cursorcolumn = false
    on_enter('cursorcolumn', window)
end

M.toggle_cursorcolumn = function()
    local window = vim.api.nvim_get_current_win()
    enabled.cursorcolumn = not enabled.cursorcolumn
    on_enter('cursorcolumn', window)
end

M.has_cursorcolumn = function()
    return enabled.cursorcolumn
end

M.enable_cursorcross = function()
    M.enable_cursorline()
    M.enable_cursorcolumn()
end

M.disable_cursorcross = function()
    M.disable_cursorline()
    M.disable_cursorcolumn()
end

M.toggle_cursorcross = function()
    if enabled.cursorcolumn then
        M.disable_cursorcross()
    else
        M.enable_cursorcross()
    end
end

M.has_cursorcross = function()
    return enabled.cursorline and enabled.cursorcolumn
end

return M
