local M = {}

local defaults = {
    follow = {
        cursorline = true,
        cursorcolumn = true,
    },
    disable_in_insert = true,
    always_highlight_number = false,
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
            'DressingInput',
        },
        cursorcolumn = {},
    },
    ignore = {
        cursorline = {},
        cursorcolumn = {},
    },
}

M.init = function(user_conf)
    user_conf = user_conf or {}
    M.settings = vim.tbl_deep_extend('force', defaults, user_conf)
end

return M
