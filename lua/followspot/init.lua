local M = {}

local config = require('followspot.config')
local set_opt = vim.api.nvim_win_set_option
local get_opt = vim.api.nvim_win_get_option
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local contains = vim.tbl_contains
local vim_enter = true
local enabled = {
    cursorline = false,
    cursorcolumn = false,
}

local update_enter = function(opt, settings, win_id)
    local ft = vim.api.nvim_buf_get_option(0, 'filetype')
    if contains(settings.never[opt], ft) then
        set_opt(win_id, opt, false)
    elseif contains(settings.on_focus[opt], ft) or
        contains(settings.always[opt], ft) then
        set_opt(win_id, opt, true)
    elseif settings.follow[opt] then
        if enabled[opt] then
            set_opt(win_id, opt, true)
        else
            set_opt(win_id, opt, false)
        end
    end
end

local on_enter = function(settings)
    -- Don't do anything for special buffers
    if contains({
        'nofile',
        'quickfix',
        'terminal',
        'prompt',
    }, vim.bo.buftype) then return end
    local win_id = vim.api.nvim_get_current_win()
    if vim_enter then
        enabled.cursorline = get_opt(win_id, 'cursorline')
        enabled.cursorcolumn = get_opt(win_id, 'cursorcolumn')
        vim_enter = false
    end
    update_enter('cursorline', settings, win_id)
    update_enter('cursorcolumn', settings, win_id)
end

local update_leave = function(opt, settings)
    local ft = vim.api.nvim_buf_get_option(0, 'filetype')
    if not contains(settings.always[opt], ft) then
        if contains(settings.on_focus[opt], ft) or settings.follow[opt] then
            set_opt(0, opt, false)
        end
    end
end

local on_leave = function(settings)
    update_leave('cursorline', settings)
    update_leave('cursorcolumn', settings)
end

local on_option_change = function()
    local win_id = vim.api.nvim_get_current_win()
    local win_type = vim.fn.win_gettype(win_id)
    if win_type == '' then
        local buf_nr = vim.fn.winbufnr(win_id)
        local buf_type = vim.api.nvim_buf_get_option(buf_nr, 'buftype')
        if not contains({
            'nofile',
            'quickfix',
            'terminal',
            'prompt',
        }, buf_type) then
            enabled.cursorline = get_opt(win_id, 'cursorline')
            enabled.cursorcolumn = get_opt(win_id, 'cursorcolumn')
        end
    end
end

local register_autocmds = function()
    local settings = config.settings
    local group = augroup('Reticle', { clear = true })
    autocmd({ 'WinEnter', 'BufWinEnter' }, {
        callback = function() on_enter(settings) end,
        group = group,
    })
    autocmd('WinLeave', {
        callback = function() on_leave(settings) end,
        group = group,
    })
    autocmd('OptionSet', {
        pattern = { 'cursorline', 'cursorcolumn' },
        callback = function() on_option_change() end,
        group = group,
    })
end

M.setup = function(user_config)
    config.init(user_config)
    register_autocmds()
end

return M
