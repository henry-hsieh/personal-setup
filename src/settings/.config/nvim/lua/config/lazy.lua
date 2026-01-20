local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- LazyFile
local Event = require("lazy.core.handler.event")

Event.mappings.LazyFile = { id = "LazyFile", event = { "BufReadPost", "BufNewFile", "BufWritePre" } }
Event.mappings["User LazyFile"] = Event.mappings.LazyFile

local spec = {
  { import = "plugins" },
}

local custom_plugins_path = vim.fn.stdpath("config") .. "/lua/custom/plugins"
if vim.uv.fs_stat(custom_plugins_path) then
  table.insert(spec, { import = "custom.plugins" })
end

require("lazy").setup(spec, {
  defaults = {
    lazy = true,
  },
})
