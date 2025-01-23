local M = {}

local defaults = {
    on_startup = {
        cursorline = true,
        cursorcolumn = false,
    },
    follow = {
        cursorline = true,
        cursorcolumn = true,
    },
    disable_in_insert = true,
    disable_in_diff = true,
    always_highlight_number = false,
    always = {
        cursorline = {},
        cursorcolumn = {},
    },
    on_focus = {
        cursorline = {},
        cursorcolumn = {},
    },
    ignore = {
        cursorline = {
            'DressingInput',
            'FTerm',
            'NvimSeparator',
            'NvimTree',
            'TelescopePrompt',
            'Trouble',
        },
        cursorcolumn = {},
    },
    never = {
        cursorline = {},
        cursorcolumn = {},
    },
}

M.option_check = function(dict1, dict2, path)
    path = path or 'reticle.opts'
    if vim.islist(dict1) and vim.islist(dict2) then
        return
    end
    if not vim.tbl_isempty(dict2) and vim.islist(dict2) then
        error(string.format("'%s' should be a dictionary-like table", path))
    end
    if vim.islist(dict1) then
        error(string.format("'%s' should be an array-like table.", path))
    end
    for key2, value2 in pairs(dict2) do
        local value1 = dict1[key2]
        if value1 == nil then
            error(string.format("'%s' is not a valid key of %s", key2, path))
        end
        if type(value1) ~= type(value2) then
            error(string.format("'%s.%s' should be from type %s", path, key2, type(value1)))
        end
        if type(value2) == "table" then
            M.option_check(value1, value2, path .. '.' .. key2)
        end
    end
end

M.get_settings = function(user_conf)
    user_conf = user_conf or {}
    M.option_check(defaults, user_conf)
    return vim.tbl_deep_extend('force', defaults, user_conf)
end

return M
