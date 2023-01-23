local M = {}

local defaults = {
    follow = {
        cursorline = true,
        cursorcolumn = true,
        -- winhighlight = false,
    },
    always = {
        cursorline = {
            -- 'help',
        },
        cursorcolumn = {
            -- 'help',
        },
    },
    always_on_focus = {
        cursorline = {
            'help',
            -- 'lua',
        },
        cursorcolumn = {
            -- 'help',
        },
    },
    never = {
        cursorline = {
            'python',
        },
        cursorcolumn = {
            'TelescopePrompt',
        },
    },
}

M.init = function(user_conf)
    user_conf = user_conf or {}
    M.options = vim.tbl_deep_extend('force', defaults, user_conf)
end

return M
