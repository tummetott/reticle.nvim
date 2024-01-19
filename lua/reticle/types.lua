-- User options are optional. We merge all missing values with the default
--- @class reticle.filetypeopts
--- @field cursorline? string[]
--- @field cursorcolumn? string[]

--- @class reticle.enabledopts
--- @field cursorline? boolean
--- @field cursorcolumn? boolean

--- @class reticle.opts
--- @field on_startup? reticle.enabledopts
--- @field disable_in_insert? boolean
--- @field always_highlight_number? boolean
--- @field follow? reticle.enabledopts
--- @field always? reticle.filetypeopts
--- @field on_focus? reticle.filetypeopts
--- @field never? reticle.filetypeopts
--- @field ignore? reticle.filetypeopts

-- After combining the user-configured options with the default options, we
-- require new annotations that are no longer optional. These annotations serve
-- for internal usage within the plugin.
--- @class reticle.filetypeopts_internal
--- @field cursorline string[]
--- @field cursorcolumn string[]

--- @class reticle.enabledopts_internal
--- @field cursorline boolean
--- @field cursorcolumn boolean

--- @class reticle.opts_internal
--- @field on_startup reticle.enabledopts_internal
--- @field disable_in_insert boolean
--- @field always_highlight_number boolean
--- @field follow reticle.enabledopts_internal
--- @field always reticle.filetypeopts_internal
--- @field on_focus reticle.filetypeopts_internal
--- @field never reticle.filetypeopts_internal
--- @field ignore reticle.filetypeopts_internal
