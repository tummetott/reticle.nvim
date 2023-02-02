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
        cursorline = {
            'TelescopePrompt',
        },
        cursorcolumn = {},
    },
    ignore = {
        cursorline = {
            'NvimTree',
        },
        cursorcolumn = {},
    },
    always_show_cl_number = false,
}

M.init = function(user_conf)
    user_conf = user_conf or {}
    M.settings = vim.tbl_deep_extend('force', defaults, user_conf)
end

return M
