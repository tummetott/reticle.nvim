local M = {}

local conf = require('reticle.config')
local settings = nil -- We update this value once the config is parsed
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local contains = vim.tbl_contains
local vim_enter = true

-- This state is accessible from other plugins, e.g. unimpaired.nvim uses it to
-- properly toggle the cursorline when 'always_show_cl_number' is set
M.enabled = {
    cursorline = false,
    cursorcolumn = false,
}

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
        return
    end
    win_set_option(window, opt, enable)
end

-- This function implements the logic whether and option is turned on or off on
-- window enter, depending on the filetype of the window and the user
-- configuration. The function is deferred in order to get the correct filetype
local update_option_enter = function(opt, window)
    vim.schedule(function()
        -- Exit if window does not exist anymore after deferring
        if vim.fn.win_id2win(window) == 0 then return end
        local ft = vim.bo.filetype
        if contains(settings.ignore[opt], ft) then
            return
        elseif contains(settings.never[opt], ft) then
            enable_option(window, opt, false)
        elseif contains(settings.on_focus[opt], ft) or
            contains(settings.always[opt], ft) then
            enable_option(window, opt, true)
        elseif settings.follow[opt] then
            enable_option(window, opt, M.enabled[opt])
        end
    end)
end

-- This function implements the logic whether and option is turned on or off on
-- window leave, depending on the filetype of the window and the user
-- configuration. The function is deferred in order to get the correct filetype
local update_option_leave = function(opt, window)
    vim.schedule(function()
        -- Exit if window does not exist anymore after deferring
        if vim.fn.win_id2win(window) == 0 then return end
        local ft = vim.bo.filetype
        if contains(settings.ignore[opt], ft) then
            return
        elseif contains(settings.always[opt], ft) then
            enable_option(window, opt, true)
        elseif contains(settings.never[opt], ft) or
            contains(settings.on_focus[opt], ft) or
            settings.follow[opt] then
            enable_option(window, opt, false)
        end
    end)
end

-- When first entering vim, we must retrieve the initial cursorline and
-- cursorcolumn setting and init our plugin state
local on_vim_enter = function(window)
    M.enabled.cursorline = vim.wo.cursorline
    M.enabled.cursorcolumn = vim.wo.cursorcolumn
    -- In order to always show the number, cursorline must remain switched on
    if settings.always_show_cl_number then
        win_set_option(window, 'cursorline', true)
    end
    -- Prevent executing this function again
    vim_enter = false
end

local on_enter = function()
    local window = vim.api.nvim_get_current_win()
    if vim_enter then on_vim_enter(window) end
    update_option_enter('cursorline', window)
    update_option_enter('cursorcolumn', window)
end

local on_leave = function()
    local window = vim.api.nvim_get_current_win()
    update_option_leave('cursorline', window )
    update_option_leave('cursorcolumn', window)
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
        M.enabled.cursorline = vim.wo.cursorline
        if settings.always_show_cl_number then
            win_set_option(window, 'cursorline', true)
            update_option_enter('cursorline', window)
        end
    elseif state.match == 'cursorcolumn' then
        M.enabled.cursorcolumn = vim.wo.cursorcolumn
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

return M
