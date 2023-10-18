local M = {}

require 'reticle.types'

--- @type ReticleOpts
local defaults = {
    on_startup = {
        cursorline = false,
        cursorcolumn = false,
    },
    disable_in_insert = true,
    always_highlight_number = false,
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
            'DressingInput',
        },
        cursorcolumn = {
            'DressingInput',
        },
    },
    ignore = {
        cursorline = {
            'TelescopePrompt',
            'NvimTree',
            'Trouble',
            'NvimSeparator',
        },
        cursorcolumn = {
            'TelescopePrompt',
            'NvimTree',
            'Trouble',
            'NvimSeparator',
        },
    },
}

---@param user_conf? ReticleUserOpts
---@return ReticleOpts
M.get_settings = function(user_conf)
    user_conf = user_conf or {}
    return vim.tbl_deep_extend('force', defaults, user_conf)
end

return M
