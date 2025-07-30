require('plugin-settings')
if require('utils').file_exists(vim.fn.stdpath('config') .. '/lua/custom-settings.lua') then
  require('custom-settings')
end
require('settings')
require('plugins')
require('telescope-settings')
