local M = {}

local config = require('followspot.config')
local set_option = vim.api.nvim_win_set_option
local get_option = vim.api.nvim_win_get_option
local contains = vim.tbl_contains
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

M.setup = function(user_config)
    config.init(user_config)
    M.set_autocmds()
end

local cursorline_enabled = false
local cursorcolumn_enabled = false

-- local cl_charge = false
-- local cc_charge = false
-- local last_cl_charge = false
-- local last_cc_charge = false
-- local last_cc = false
-- local last_cl = false
-- local last_win = -1

-- local rewind_state = function(win)
--     if win == last_win then
--         if last_cl then cl = true end
--         if last_cc then cc = true end
--     end
--     last_win = win
--     last_cl = cl
--     last_cc = cc
-- end

local on_enter = function(opt)
    -- Don't do anything for special buffers
    if contains({
        'nofile',
        'quickfix',
        'terminal',
        'prompt',
    }, vim.bo.buftype) then return end

    local win = vim.api.nvim_get_current_win()
    local ft = vim.bo.filetype

    -- print('enter: ' .. tostring(win))
    if win == last_win then
        set_option(win, 'cursorline', false)
        set_option(win, 'cursorcolumn', false)
        cl_charge = last_cl_charge
        cc_charge = last_cc_charge
    end

    last_win = win
    last_cl_charge = cl_charge
    last_cc_charge = cc_charge

    if not contains(opt.never.cursorline, vim.bo.filetype) then
        if contains(opt.always.cursorline, ft) or contains(opt.always_on_focus.cursorline, ft) then
            set_option(win, 'cursorline', true)
        elseif opt.follow.cursorline and cl_charge then
            set_option(win, 'cursorline', true)
            cl_charge = false
        end
    end

    if not contains(opt.never.cursorcolumn, vim.bo.filetype) then
        if contains(opt.always.cursorcolumn, ft) or contains(opt.always_on_focus.cursorcolumn, ft) then
            set_option(win, 'cursorcolumn', true)
        elseif opt.follow.cursorcolumn and cc_charge then
            set_option(win, 'cursorcolumn', true)
            cc_charge = false
        end
    end
end

local on_leave = function(opt)
    local win_id = vim.api.nvim_get_current_win()
    -- print('leave: ' .. tostring(win))
    if not contains(opt.always.cursorline, vim.bo.filetype) then
        if contains(opt.always_on_focus.cursorline, vim.bo.filetype) then
            set_option(0, 'cursorline', false)
        elseif opt.follow.cursorline and get_option(win_id, 'cursorline') then
            set_option(0, 'cursorline', false)
            print('charged')
            cl_charge = true
        end
    end
    if not contains(opt.always.cursorcolumn, vim.bo.filetype) then
        if contains(opt.always_on_focus.cursorcolumn, vim.bo.filetype) then
            set_option(0, 'cursorcolumn', false)
        elseif opt.follow.cursorcolumn and get_option(win_id, 'cursorcolumn') then
            set_option(0, 'cursorcolumn', false)
            cc_charge = true
        end
    end
end

-- TODO: what if first file is in always?
-- what if first file is in never?

-- To be deleted
-- vim.cmd [[setlocal cursorline]]

local on_vim_enter = function(opt)
    local win = vim.api.nvim_get_current_win()
    -- last_win = win
    -- if get_option(win, 'cursorline') then
    --     last_cl_charge = true
    -- end
    -- if get_option(win, 'cursorcolumn') then
    --     last_cc_charge = true
    -- end
end

local option_changed = function(opt)
    local win_id = vim.api.nvim_get_current_win()
    local win_type = vim.fn.win_gettype(win_id)
    if win_type == '' then
        local buf_nr = vim.fn.winbufnr(win_id)
        local buf_type = vim.api.nvim_buf_get_option(buf_nr, 'buftype')
        if buf_type == '' then
            cursorline_enabled = get_option(win_id, 'cursorline')
            cursorcolumn_enabled = get_option(win_id, 'cursorcolumn')
            print(cursorline_enabled)
        end
    end
end

M.set_autocmds = function()
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
    autocmd('VimEnter', {
        callback = function() on_vim_enter(opt) end,
        group = group,
    })
    autocmd('OptionSet', {
        pattern = { 'cursorline', 'cursorcolumn' },
        callback = function() option_changed(opt) end,
        group = group,
    })
end

return M
