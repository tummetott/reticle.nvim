local M = {}

local conf = require('reticle.config')
local settings = nil -- We update this value once the config is parsed
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local contains = vim.tbl_contains
local vim_enter = true
local enabled = { cursorline = false, cursorcolumn = false }

-- This wrapper function sets a window local option for the focused window
-- without triggering the 'OptionSet' event
local win_set_option = function(window, name, value)
    local eventignore = vim.opt.eventignore:get()
    vim.opt.eventignore:append('OptionSet')
    vim.api.nvim_win_set_option(window, name, value)
    vim.opt.eventignore = eventignore
end

-- This function translates the semantic meaning of enabling a general option to
-- the actual call how to enable the specific option
local enable_option = function(window, opt, enable)
    if opt == 'cursorline' and settings.always_show_cl_number then
        win_set_option(window, 'cursorlineopt', enable and 'both' or 'number')
        win_set_option(window, 'cursorline', true)
    else
        win_set_option(window, opt, enable)
    end
end

-- This function implements the logic whether and option is turned on or off on
-- window enter, depending on the filetype of the window and the user
-- configuration.
local update_option_on_enter = function(opt, window)
    local buffer = vim.api.nvim_win_get_buf(window)
    local ft = vim.api.nvim_buf_get_option(buffer, 'filetype')
    if contains(settings.ignore[opt], ft) then
        return
    elseif contains(settings.never[opt], ft) then
        enable_option(window, opt, false)
    elseif contains(settings.on_focus[opt], ft) or
        contains(settings.always[opt], ft) then
        enable_option(window, opt, true)
    elseif settings.follow[opt] then
        enable_option(window, opt, enabled[opt])
    end
end

-- This function implements the logic whether and option is turned on or off on
-- window leave, depending on the filetype of the window and the user
-- configuration.
local update_option_on_leave = function(opt, window)
    local buffer = vim.api.nvim_win_get_buf(window)
    local ft = vim.api.nvim_buf_get_option(buffer, 'filetype')
    if contains(settings.ignore[opt], ft) then
        return
    elseif contains(settings.always[opt], ft) then
        enable_option(window, opt, true)
    elseif contains(settings.never[opt], ft) or
        contains(settings.on_focus[opt], ft) or
        settings.follow[opt] then
        enable_option(window, opt, false)
    end
end

-- This wrapper function delays the update_option_on_enter in order to get the
-- correct filetype
local deferred_update_option_on_enter = function(opt, window)
    vim.schedule(function()
        -- Exit if window does not exist anymore after deferring
        if vim.fn.win_id2win(window) == 0 then return end
        update_option_on_enter(opt, window)
    end)
end

-- This wrapper function delays the update_option_on_leave in order to get the
-- correct filetype
local deferred_update_option_on_leave = function(opt, window)
    vim.schedule(function()
        -- Exit if window does not exist anymore after deferring
        if vim.fn.win_id2win(window) == 0 then return end
        update_option_on_leave(opt, window)
    end)
end

local on_enter = function()
    local window = vim.api.nvim_get_current_win()
    -- When first entering vim, we must retrieve the initial cursorline and
    -- cursorcolumn setting and init our plugin state
    if vim_enter then
        enabled.cursorline = vim.wo.cursorline
        enabled.cursorcolumn = vim.wo.cursorcolumn
        update_option_on_enter('cursorline', window)
        update_option_on_enter('cursorcolumn', window)
        vim_enter = false
    else
        deferred_update_option_on_enter('cursorline', window)
        deferred_update_option_on_enter('cursorcolumn', window)
    end
end

local on_leave = function()
    local window = vim.api.nvim_get_current_win()
    deferred_update_option_on_leave('cursorline', window)
    deferred_update_option_on_leave('cursorcolumn', window)
end

-- Many plugins set a local cursorline in their windows and forget supression
-- the OptionSet event. We must therefore filter every OptionSet event for
-- cursorline / cursorcolumn changes by the user. As soon as we can be sure that
-- the user changed the setting, we update our plugin state
local on_option_change = function(state)
    local window = vim.api.nvim_get_current_win()
    local win_type = vim.fn.win_gettype(window)
    local buf_type = vim.bo.buftype
    if contains({ 'command', 'autocmd' }, win_type) then return end
    if contains({ 'nofile', 'prompt' }, buf_type) then return end
    if state.match == 'cursorline' then
        enabled.cursorline = vim.wo.cursorline
        update_option_on_enter('cursorline', window)
    elseif state.match == 'cursorcolumn' then
        enabled.cursorcolumn = vim.wo.cursorcolumn
        update_option_on_enter('cursorcolumn', window)
    end
end

local register_autocmds = function()
    local group = augroup('Reticle', { clear = true })
    autocmd({ 'WinEnter', 'BufWinEnter' }, {
        callback = function() on_enter() end,
        group = group,
    })
    autocmd('WinLeave', {
        callback = function() on_leave() end,
        group = group,
    })
    autocmd('OptionSet', {
        pattern = { 'cursorline', 'cursorcolumn' },
        callback = function(state) on_option_change(state) end,
        group = group,
    })
end

M.setup = function(user_config)
    conf.init(user_config)
    settings = conf.settings
    register_autocmds()
end

-- The following are utility functions which can be used for keymaps or other
-- plugins (e.g. unimpaired.nvim)
M.enable_cursorline = function()
    local window = vim.api.nvim_get_current_win()
    enabled.cursorline = true
    update_option_on_enter('cursorline', window)
end

M.disable_cursorline = function()
    local window = vim.api.nvim_get_current_win()
    enabled.cursorline = false
    update_option_on_enter('cursorline', window)
end

M.toggle_cursorline = function()
    local window = vim.api.nvim_get_current_win()
    enabled.cursorline = not enabled.cursorline
    update_option_on_enter('cursorline', window)
end

M.is_cursorline = function()
    return enabled.cursorline
end

return M
