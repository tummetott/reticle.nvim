local M = {}

local config = require('followspot.config')
local set_opt = vim.api.nvim_win_set_option
local get_opt = vim.api.nvim_win_get_option
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local contains = vim.tbl_contains
local cursorline_enabled = false
local cursorcolumn_enabled = false
local vim_enter = true

local on_enter = function(opt)
    -- Don't do anything for special buffers
    if contains({
        'nofile',
        'quickfix',
        'terminal',
        'prompt',
    }, vim.bo.buftype) then return end
    local win_id = vim.api.nvim_get_current_win()
    local ft = vim.api.nvim_buf_get_option(0, 'filetype')
    if vim_enter then
        cursorline_enabled = get_opt(win_id, 'cursorline')
        cursorcolumn_enabled = get_opt(win_id, 'cursorcolumn')
        vim_enter = false
    end
    if contains(opt.never.cursorline, ft) then
        set_opt(win_id, 'cursorline', false)
    elseif contains(opt.on_focus.cursorline, ft) or
        contains(opt.always.cursorline, ft) then
        set_opt(win_id, 'cursorline', true)
    elseif opt.follow.cursorline then
        if cursorline_enabled then
            set_opt(win_id, 'cursorline', true)
        else
            set_opt(win_id, 'cursorline', false)
        end
    end
    if contains(opt.never.cursorcolumn, ft) then
        set_opt(win_id, 'cursorcolumn', false)
    elseif contains(opt.on_focus.cursorcolumn, ft) or
        contains(opt.always.cursorcolumn, ft) then
        set_opt(win_id, 'cursorcolumn', true)
    elseif opt.follow.cursorcolumn then
        if cursorcolumn_enabled then
            set_opt(win_id, 'cursorcolumn', true)
        else
            set_opt(win_id, 'cursorcolumn', false)
        end
    end
end

local on_leave = function(opt)
    local ft = vim.bo.filetype
    if not contains(opt.always.cursorline, ft) then
        if contains(opt.on_focus.cursorline, ft) or opt.follow.cursorline then
            set_opt(0, 'cursorline', false)
        end
    end
    if not contains(opt.always.cursorcolumn, ft) then
        if contains(opt.on_focus.cursorcolumn, ft) or opt.follow.cursorcolumn then
            set_opt(0, 'cursorcolumn', false)
        end
    end
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
            cursorline_enabled = get_opt(win_id, 'cursorline')
            cursorcolumn_enabled = get_opt(win_id, 'cursorcolumn')
        end
    end
end

local register_autocmds = function()
    local opt = config.options
    local group = augroup('Followspot', { clear = true })
    autocmd({ 'WinEnter', 'BufWinEnter' }, {
        callback = function() on_enter(opt) end,
        group = group,
    })
    autocmd('WinLeave', {
        callback = function() on_leave(opt) end,
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
