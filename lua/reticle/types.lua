--- @class ReticleFiletypeOpts
--- @field cursorline? string[]
--- @field cursorcolumn? string[]

--- @class ReticleCursorOpts
--- @field cursorline? boolean
--- @field cursorcolumn? boolean

--- @class ReticleOpts
--- @field on_startup ReticleCursorOpts
--- @field disable_in_insert boolean
--- @field always_highlight_number boolean
--- @field follow ReticleCursorOpts
--- @field always ReticleFiletypeOpts
--- @field on_focus ReticleFiletypeOpts
--- @field never ReticleFiletypeOpts
--- @field ignore ReticleFiletypeOpts

-- We merge the user's configuration with the default settings, giving them the flexibility to
-- customize only the specific fields they choose while leaving the rest at their default values.
-- This is achieved by creating a second type with all fields marked as optional.
--- @class ReticleUserOpts
--- @field on_startup? ReticleCursorOpts
--- @field disable_in_insert? boolean
--- @field always_highlight_number? boolean
--- @field follow? ReticleCursorOpts
--- @field always? ReticleFiletypeOpts
--- @field on_focus? ReticleFiletypeOpts
--- @field never? ReticleFiletypeOpts
--- @field ignore? ReticleFiletypeOpts
