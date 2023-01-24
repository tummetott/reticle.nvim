local M = {}

local conf = require('reticle.config')
local settings = nil -- We update this value once the config is parsed
local get_opt = vim.api.nvim_win_get_option
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local contains = vim.tbl_contains
local vim_enter = true
local enabled = {
    cursorline = false,
    cursorcolumn = false,
}

local set_opt = function(win_id, opt, value)
    if opt == 'cursorline' and settings.always_show_cl_number then
        if value then value = 'both' else value = 'number' end
        opt = 'cursorlineopt'
    end
    vim.api.nvim_win_set_option(win_id, opt, value)
end

local on_vim_enter = function(win_id)
    settings = conf.settings
    -- Get the initial state from the options the user put in the vimrc
    enabled.cursorline = get_opt(win_id, 'cursorline')
    enabled.cursorcolumn = get_opt(win_id, 'cursorcolumn')
    if settings.always_show_cl_number then
        -- In order to always show the number, cursorline must remain switched on
        vim.api.nvim_win_set_option(win_id, 'cursorline', true)
    end
    -- Prevent executing this function again
    vim_enter = false
end

local update_enter = function(opt, win_id)
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

local on_enter = function()
    -- Don't do anything for special buffers
    if contains({
        'nofile',
        'quickfix',
        'terminal',
        'prompt',
    }, vim.bo.buftype) then return end
    local win_id = vim.api.nvim_get_current_win()
    if vim_enter then on_vim_enter(win_id) end
    update_enter('cursorline', win_id)
    update_enter('cursorcolumn', win_id)
end

local update_leave = function(opt, win_id)
    local ft = vim.api.nvim_buf_get_option(0, 'filetype')
    if not contains(settings.always[opt], ft) then
        if contains(settings.on_focus[opt], ft) or
            settings.follow[opt] then
            set_opt(win_id, opt, false)
        end
    end
end

local on_leave = function()
    local win_id = vim.api.nvim_get_current_win()
    update_leave('cursorline', win_id)
    update_leave('cursorcolumn', win_id)
end

-- Many plugins set a local cursorline in their windows. We must therefore
-- filter for cursorline / cursorcolumn switches performed by the user
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
            -- Now we can be sure that the there is a valid switch, so we first update our state
            enabled.cursorline = get_opt(win_id, 'cursorline')
            enabled.cursorcolumn = get_opt(win_id, 'cursorcolumn')
            if settings.always_show_cl_number then
                -- In order to always show the number, cursorline must remain
                -- switched on
                vim.api.nvim_win_set_option(win_id, 'cursorline', true)
                update_enter('cursorline', win_id)
            else
            end
        end
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
        callback = function() on_option_change() end,
        group = group,
    })
end

M.setup = function(user_config)
    conf.init(user_config)
    register_autocmds()
end

return M
