# Changelog

## [1.0.2](https://github.com/tummetott/reticle.nvim/compare/v1.0.1...v1.0.2) (2025-01-23)


### Bug Fixes

* replace deprecated `tbl_islist` by `islist` ([696e120](https://github.com/tummetott/reticle.nvim/commit/696e1204c613d148b393ecfac0b4ba84d09f6ac4))
* replace missed `tbl_islist` ([f39f1da](https://github.com/tummetott/reticle.nvim/commit/f39f1da5a70e6085a29f39ab9b0c6b029d6fe633))

## [1.0.1](https://github.com/tummetott/reticle.nvim/compare/v1.0.0...v1.0.1) (2024-05-13)


### Bug Fixes

* dont detect floating windows, only highlight the current window. Closes [#11](https://github.com/tummetott/reticle.nvim/issues/11) ([1aa463b](https://github.com/tummetott/reticle.nvim/commit/1aa463be8946359447d78e77d8865f0469d4c254))

## 1.0.0 (2024-04-02)


### Features

* added a proper vimdoc documentation ([0ff1af9](https://github.com/tummetott/reticle.nvim/commit/0ff1af93808c47b7dac3346df49435a508758f90))
* cursorline and cursorcolumn automatically disabled in insert mode. Can be configured ([983fb8b](https://github.com/tummetott/reticle.nvim/commit/983fb8b57390572696a81947ed5093abe499fc7e))
* disable cursorline and cursorcolumn in diff mode ([262e381](https://github.com/tummetott/reticle.nvim/commit/262e381f68b4e547b780bc334e9524635eba3d45))
* Special filetype rules defined by the user in reticle.opts are overruled by runtime changes by the user through the API function. ([c6c27a4](https://github.com/tummetott/reticle.nvim/commit/c6c27a48b77af05d9461006b6a954f2d6d5f3a37))


### Bug Fixes

* 9: Hide the cursorline in diagnostic floats ([5c95587](https://github.com/tummetott/reticle.nvim/commit/5c95587409420b86d1005c855131d5447db810ef))
* added lazyloading for lazy.nvim in README ([0135b7d](https://github.com/tummetott/reticle.nvim/commit/0135b7d171e9c5abb80e56557db11e39a9a68785))
* better description for reticle.opts annotations. feat: plugin checks the user config for errors ([38e0a00](https://github.com/tummetott/reticle.nvim/commit/38e0a007658abf4d64dd9ff773bb1e728ca93d3a))
* changes on the cursorline and/or cursorcolumn setting are not picked up by the plugin automatically anymore (upon the "OptionChange" event). The plugin overrules the cursorline setting, updating its inner state only when appropriate user functions or user commands are called. Fixes [#2](https://github.com/tummetott/reticle.nvim/issues/2) [#3](https://github.com/tummetott/reticle.nvim/issues/3) [#4](https://github.com/tummetott/reticle.nvim/issues/4) ([b87fdc0](https://github.com/tummetott/reticle.nvim/commit/b87fdc033d98b80f07ee01902a1298bb274580e4))
* dont highlight the separator when using colorful-winsep.nvim. Closes [#3](https://github.com/tummetott/reticle.nvim/issues/3) ([800d14d](https://github.com/tummetott/reticle.nvim/commit/800d14d07effbbbd0bfe49c45e199353b7cb5f16))
* initialize the split windows, no matter if the plugin is lazy loaded or not ([4adfeed](https://github.com/tummetott/reticle.nvim/commit/4adfeed88764ea45a2b4389187cd94230611d18e))
* lazyloading issue with packer. Updated readme on lazyloading ([ca48b2a](https://github.com/tummetott/reticle.nvim/commit/ca48b2ab1ba206d050ea98ec5dc766e1cacc5196))
* missing "=" in README.md ([8313d12](https://github.com/tummetott/reticle.nvim/commit/8313d1293a346b6b2d8fbc37fb07fcdad45a8b8e))
* **README:** syntax & typo correction ([238d103](https://github.com/tummetott/reticle.nvim/commit/238d10318d9efa9a46e6925620557b90b35197f8))
* typo in README ([ddca2b6](https://github.com/tummetott/reticle.nvim/commit/ddca2b689bb4b343eb5b1007f619c98acf98815f))
* typo in README ([f82e860](https://github.com/tummetott/reticle.nvim/commit/f82e8608235e1187141ad1b39a6cc2ac0c64f42a))
* typo in README ([d813899](https://github.com/tummetott/reticle.nvim/commit/d81389931cc1073846eea76d59512dfffb55c131))
* update split windows on startup when opening neovim with flags like -O or -d etc ([95d3424](https://github.com/tummetott/reticle.nvim/commit/95d3424cf71f0d7e79100d546d04b9c9583a0216))
