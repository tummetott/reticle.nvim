local M = {}

local defaults = {
    follow = {
        cursorline = true,
        cursorcolumn = true,
    },
    always = {
        cursorline = {},
        cursorcolumn = {},
    },
    on_focus = {
        cursorline = {},
        cursorcolumn = {},
    },
    never = {
        cursorline = {},
        cursorcolumn = {},
    },
    always_show_cl_number = true,
}

M.init = function(user_conf)
    user_conf = user_conf or {}
    M.settings = vim.tbl_deep_extend('force', defaults, user_conf)
end

return M
