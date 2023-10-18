# reticle.nvim

<p align="center">
  <img src="./reticle.png" alt="reticle" width="200" height="200" />
</p>

### :pencil: Description:

The `cursorline` and `cursorcolumn` settings are designed to facilitate the visual identification of the cursor's position. However, there are situations where enabling these settings is not always desirable. For instance, when multiple split windows are open, each one displays its own cursorline, creating difficulty in distinguishing the active window.

This plugin provides a convenient solution for configuring the `cursorline` and `cursorcolumn` settings to meet your specific needs, granting you complete control over when they are displayed and when they are not.

### 🎥 Preview:

![preview](./preview.gif)


### ✨ Features

- 🚶 Cursorline and/or cursorcolumn follow the active window.
- ♾️  Specify filetypes that consistently display the cursorline and/or cursorcolumn.
- 👀 Specify filetypes that always show the cursorline and/or cursorcolumn when a window is focused, regardless of the cursorline and/or cursorcolumn setting.
- ❌ Specify filetypes that never display the cursorline and/or cursorcolumn.
- 🔦 Always highlight the (less intrusive) cursorline number in all windows, regardless of the cursorline setting.
- 💨 Developed in Lua instead of Vimscript.


### ⚡️ Requirements

- Neovim >= 0.5.0


### 📦 Installation

Install the plugin with your favorite package manager and place the following code somewhere in your Lua configurations:

```lua
require('reticle').setup {
    -- add options here if you wish to override the default settings
}
```

Installing `reticle.nvim` with 💤 [lazy](https://github.com/folke/lazy.nvim):

<details><summary>Click me</summary>

```lua
{
    'tummetott/reticle.nvim',
    event = 'VeryLazy', -- optionally lazy load the plugin
    opts = {
        -- add options here if you wish to override the default settings
    },
}
```

</details>

Installing `reticle.nvim` with 📦 [packer](https://github.com/wbthomason/packer.nvim):

<details><summary>Click me</summary>

```lua
use {
    'tummetott/reticle.nvim',
    config = function()
        require('reticle').setup {
            -- add options here if you wish to override the default settings
        }
    end
}
```

</details>


### 🚀 Usage

If you prefer to have your cursorline and/or cursorcolumn enabled at startup, you can adjust the `opts.on_startup` setting. See: **Configuration**

To modify the cursorline and/or cursorcolumn settings while using Nvim, you can make use of the following user-exposed functions. These functions can be mapped to keybindings of your choice.

```lua
require'reticle'.enable_cursorline()
require'reticle'.disable_cursorline()
require'reticle'.toggle_cursorline()

require'reticle'.enable_cursorcolumn()
require'reticle'.disable_cursorcolumn()
require'reticle'.toggle_cursorcolumn()

-- Cursorcross combines both the cursorline and cursorcolumn
require'reticle'.enable_cursorcross()
require'reticle'.disable_cursorcross()
require'reticle'.toggle_cursorcross()
```

<details><summary>Example keymappings</summary>

The following example illustrates how to create custom keymaps for the mentioned functions. Instead of manual keymap creation, you also have the option to install the [unimpaired.nvim](https://github.com/tummetott/unimpaired.nvim) plugin, which includes these keymaps by default.

```lua
-- Enable the cursorline
vim.keymap.set(
    'n',
    '[oc',
    function() require'reticle'.enable_cursorline() end,
    { desc = 'Enable the cursorline' }
)

-- Disable the cursorline
vim.keymap.set(
    'n',
    ']oc',
    function() require'reticle'.disable_cursorline() end,
    { desc = 'Disable the cursorline' }
)

-- Toggle the cursorline
vim.keymap.set(
    'n',
    'yoc',
    function() require'reticle'.toggle_cursorline() end,
    { desc = 'Toggle the cursorline' }
)

-- and so forth ...
```

</details>

Alongside the previously mentioned functions, this plugin also provides user commands to toggle the cursorline, cursorcolumn, and cursorcross.

```
:ReticleToggleCursorline
:ReticleToggleCursorcolumn
:ReticleToggleCursorcross
```

**Note**: The plugin does not automatically detect changes made to cursorline or cursorcolumn directly. Commands such as `vim.opt.cursorline = true`, `:set cursorline`, or `vim.api.nvim_win_set_option(0, 'cursorline', true)` will alter the cursorline temporarily, but the plugin will override these settings upon the following events: `WinEnter`, `WinLeave`, `BufWinEnter`, `InsertEnter`, and `InsertLeave`. Please use the above-mentioned user functions or user commands instead.

### ⚙️  Configuration

The `setup()` function takes a `opts` dictionary with user configurations. User options are merged with the default options where possible. In the event of a collision, user values take precedence and overwrite the default options. If you prefer not to customize the default behavior, you can call the function without arguments.


```lua
require('reticle').setup {
    -- Enable/Disable the cursorline and/or cursorcolumn at startup
    -- Default: false for both values
    on_startup {
        cursorline = false,
        cursorcolumn = false,
    },

    -- Disable the cursorline and cursorcolumn in insert mode
    -- Default: true
    disable_in_insert = true,

    -- By default, nvim highlights the cursorline number only when the
    -- cursorline setting is active. Enabling this setting ensures that the
    -- cursorline number in every window is always highlighted, regardless of the
    -- cursorline setting.
    -- Default: false
    always_highlight_number = true,

    -- Cursorline and/or cursorcolumn are set to be displayed exclusively in the active window,
    -- thus following your active window. This setting is overruled by the following settings
    -- concerning special filetypes.
    -- Default: true for both values
    follow = {
        cursorline = true,
        cursorcolumn = true,
    },

    -- Specify filetypes where the cursorline and/or cursorcolumn are always
    -- enabled, regardless of the global setting.
    always = {
        cursorline = {},
        cursorcolumn = {},
    },

    -- Specify filetypes where the cursorline and/or cursorcolumn are always
    -- enabled when the window is focused, regardless of the global setting.
    on_focus = {
        cursorline = {
            'help',
            'NvimTree',
        },
        cursorcolumn = {},
    },

    -- Specify filetypes where the cursorline and/or cursorcolumn are never
    -- enabled, regardless of the global setting.
    never = {
        cursorline = {
            'qf',
        },
        cursorcolumn = {
            'qf',
        },
    },

    -- Define filetypes which are ignored by the plugin
    ignore = {
        cursorline = {
            'lspinfo',
        },
        cursorcolumn = {
            'lspinfo',
        },
    },
}
```

The **default** configuration is documented in the reticle help page.
```vim
:help reticle.opts
```

#### Change highlight groups

This plugin does not alter the highlight groups for the cursorline and/or cursorcolumn. You can customize these groups as you typically would. Here are a few examples of how to modify them:

```lua
-- Underline the cursorline
vim.api.nvim_set_hl(0, 'CursorLine', { underline = true })

-- Link to other hl-group
vim.api.nvim_set_hl(0, 'CursorColumn', { link = 'Visual' })

-- Set color explicitly by defining a RGB value
vim.api.nvim_set_hl(0, 'CursorLineNr', { bg = '#FFFFFF' })
```

### 🐛 Known Issues:

- This plugin does not work with [vim-unimpaired](https://github.com/tpope/vim-unimpaired). Use [unimpaired.nivm](https://github.com/tummetott/unimpaired.nvim) instead.

### 👯 Similar Plugins:

- [vim-CursorLineCurrentWindow](https://github.com/inkarkat/vim-CursorLineCurrentWindow)
- [vim-crosshair](https://github.com/bronson/vim-crosshairs)


❤️ Tummetott
