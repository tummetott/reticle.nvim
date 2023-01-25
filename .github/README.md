# reticle.nvim

### :pencil: Description:


### ✨ Features

- 🚶 Cursorline and cursorcolumn follow the focused window
- ♾️  Define filetypes which always show cursorline and / or cursorcolumn
- 👀 Define filetypes which show cursorline and / or cursorcolumn when window is
  focused
- ❌ Define filetypes where cursorline and / or cursorcolumn are never shown
- 🔢 Highlight cursorline number even if the cursorline is switched off
- 💨 Written in LUA instead of vim script 


### ⚡️ Requirements

- Neovim >= 0.5.0


### 📦 Installation

Install the plugin with your favourite package manager.

Example using [packer](https://github.com/wbthomason/packer.nvim):

```lua
use {
    'Tummetott/reticle.nvim',
    config = function()
        require('unimpaired').setup {
            -- add options here or leave empty
        }
    end
}
```

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

}
```

##### Default Configuration
The default configuration of `reticle.nvim` looks as following:

<details><summary>Click me</summary>

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

### ⚠️  Disclaimer:

I wrote this plugin basically for myself but decided to share it afterwards.
I've tested this plugin extensively but there may still be bugs in the code.
Pull requests are welcome if you like to add more features.

x Tummetott
