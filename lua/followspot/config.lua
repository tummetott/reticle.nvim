local M = {}

local defaults = {
    follow = {
        cursorline = true,
        corsorcolumn = true,
        winhighlight = false,
    },
    always = {
        'help',
        'git',
    },
    never = {

    },
}

M.init = function(user_conf)
    user_conf = user_conf or {}
    M.options = vim.tbl_deep_extend('force', defaults, user_conf)
end

return M
