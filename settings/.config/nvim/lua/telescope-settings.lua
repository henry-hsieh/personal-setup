-- telescope-settings.lua
local M = {}

M.find_files = function()
  local opts = {}
  opts.cwd = require('utils').git_superproject(require('utils').cur_file_dir())
  opts.recurse_submodules = true
  opts.show_untracked = false
  local ok = pcall(require"telescope.builtin".git_files, opts)
  opts = {}
  opts.hidden = true
  if not ok then require"telescope.builtin".find_files(opts) end
end

M.project_files = function()
  local opts = {}
  opts.cwd = require('utils').git_superproject(require('utils').cur_file_dir())
  opts.recurse_submodules = true
  opts.show_untracked = false
  local ok = pcall(require"telescope.builtin".git_files, opts)
  opts = {}
  opts.hidden = true
  if not ok then require"telescope.builtin".find_files(opts) end
end

M.project_grep = function()
  local opts = {}
  opts.cwd = require('utils').git_superproject(require('utils').cur_file_dir())
  opts.additional_args = function()
      local args = {}
      args[1] = "--hidden"
      return args
  end
  local ok = pcall(require"telescope.builtin".live_grep, opts)
  opts.cwd = nil
  if not ok then require"telescope.builtin".live_grep(opts) end
end

-- Telescope picker
vim.api.nvim_set_keymap('n', ',t', '<cmd>Telescope<CR>', { noremap = true, silent = true })
-- Telescope project_files
vim.api.nvim_set_keymap('n', ',F', '<cmd>lua require("telescope-settings").project_files()<CR>', { noremap = true, silent = true })
-- Telescope find_files
vim.api.nvim_set_keymap('n', ',f', '<cmd>Telescope find_files hidden=true<CR>', { noremap = true, silent = true })
-- Telescope grep_string
vim.api.nvim_set_keymap('n', ',s', '<cmd>Telescope grep_string<CR>', { noremap = true, silent = true })
-- Telescope live_grep
vim.api.nvim_set_keymap('n', ',g', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true })
-- Telescope project_grep
vim.api.nvim_set_keymap('n', ',G', '<cmd>lua require("telescope-settings").project_grep()<CR>', { noremap = true, silent = true })
-- Telescope buffers
vim.api.nvim_set_keymap('n', ',b', '<cmd>Telescope buffers<CR>', { noremap = true, silent = true })

return M
