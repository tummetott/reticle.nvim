local M = {}
local config = require('followspot.config')

M.setup = function(user_config)
    config.init(user_config)
end

return M
