# reticle.nvim

<p align="center">
  <img src="./reticle.png" alt="reticle" width="200" height="200" />
</p>

### :pencil: Description:

The `cursorline` setting makes it easy to locate the cursor position. However, when there are split windows, each one shows its cursorline, and there is no good indication of the currently active window.

This plugin avoids the clutter of multiple highlighted screen lines with split windows by disabling the `cursorline` and `cursorcolumn` settings for all but the current window. Unlike a simplistic solution with a few autocmds, this plugin still allows for exceptions like disabling the `cursorline` or `cursorcolumn` for a particular filetype or making it permanent for other filetypes. Furthermore, this plugin supports highlighting the (less intrusive) cursorline number in all split windows, while the cursorline is displayed only in the focused pane.

### ✨ Features

- 🚶 Cursorline and / or cursorcolumn follow the focused window
- ♾️  Define filetypes that always show a cursorline and / or cursorcolumn
- 👀 Define filetypes that always show a cursorline and / or cursorcolumn when window is focused, regardless of the cursorline setting
- ❌ Define filetypes that never show a cursorline and / or cursorcolumn
- 🔦 Always highlight the cursorline number of all windows, regardless of the cursorline setting
- 💨 Written in LUA instead of vim script 


### ⚡️ Requirements

- Neovim >= 0.5.0


### 📦 Installation

Install the plugin with your favourite package manager and put this code
somewhere in your LUA configs:

```lua
require('reticle').setup {
    -- add options here or leave empty
}
```

Installing `reticle.nvim` with [packer](https://github.com/wbthomason/packer.nvim):

<details><summary>Click me</summary>

```lua
use {
    'Tummetott/reticle.nvim',
    config = function()
        require('reticle').setup {
            -- add options here or leave empty
        }
    end
}
```

</details>

Turn on cursorline / cursorcolumn in LUA:
```lua
vim.wo.cursorline = true
vim.wo.cursorcolumn = true
```

Turn on cursorline / cursorcolumn with an ex command:
```
:setlocal cursorline
:setlocal cursorcolumn
```


### ⚙️  Configuration

The `setup()` function takes a dictionary with user configurations. If you don't
want to customize the default behaviour, you can leave it empty

Customizing examples:

```lua
require('reticle').setup {
    -- Make the cursorline and cursorcolumn follow your active window. This
    -- only works if the cursorline and cursorcolumn setting is switched on
    -- beforehand. Default is true for both values
    follow = {
        cursorline = true,
        cursorcolumn = true,
    },

    -- Define filetypes where the cursorline / cursorcolumn is always on,
    -- regardless of the setting
    always = {
        cursorline = {
            'python',
            'text',
        },
        cursorcolumn = {
            'python',
        },
    },

    -- Define filetypes where the cursorline / cursorcolumn is always on when
    -- the window is focused, regardless of the setting
    on_focus = {
        cursorline = {
            'help',
        },
        cursorcolumn = {},
    },

    -- Define filetypes where the cursorline / cursorcolumn is never on,
    -- regardless of the setting
    never = {
        cursorline = {
            'json',
        },
        cursorcolumn = {
            'json',
        },
    },

    -- By default, nvim highlights the cursorline number only when the cursorline setting is
    -- switched on. When enabeling the following setting, the cursorline number
    -- of every window is always highlighted, regardless of the setting
    always_show_cl_number = true,
}
```

##### Change highlight groups

Change the `CursorLine`, `CursorColumn` and `CursorLineNr` hl-group as usual:

<details><summary>With ex command:</summary>

```
-- Set color explicitly by defining a RGB value
:highlight CursorLine guibg=#3C3836

-- Link to other hl-group
:highlight! link CursorLine Visual
```

</details>

<details><summary>With LUA command:</summary>

```lua
-- Set color explicitly by defining a RGB value
vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#FFFFFF' })

-- Link to other hl-group
vim.api.nvim_set_hl(0, 'CursorLine', { link = 'Visual' })

-- Underline the cursorline
vim.api.nvim_set_hl(0, 'CursorLine', { underline = true })
```

</details>

##### Default Configuration
The default configuration of `reticle.nvim` looks as following:

<details><summary>Default config</summary>

```lua
{
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
    always_show_cl_number = false,
}
```

</details>


### 👯 Similar Plugins:

- [vim-CursorLineCurrentWindow](https://github.com/inkarkat/vim-CursorLineCurrentWindow)
- [vim-crosshais](https://github.com/bronson/vim-crosshairs)

### ⚠️  Caveats:

I wrote this plugin basically for myself, but then decided to share it. The
plugin is extensively tested, but there may still be bugs in the code. Pull
requests are welcome if you want to add more features.

x Tummetott
