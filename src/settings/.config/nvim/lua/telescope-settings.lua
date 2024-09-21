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
vim.api.nvim_set_keymap('n', '<leader>T', '<cmd>Telescope<CR>', { noremap = true, silent = true, desc = "Telescope Picker" })
-- Telescope project_files
vim.api.nvim_set_keymap('n', '<leader>F', '<cmd>lua require("telescope-settings").project_files()<CR>', { noremap = true, silent = true, desc = "Find Project Files" })
-- Telescope find_files
vim.api.nvim_set_keymap('n', '<leader>f', '<cmd>Telescope find_files hidden=true<CR>', { noremap = true, silent = true, desc = "Find Files" })
-- Telescope grep_string
vim.api.nvim_set_keymap('n', '<leader>s', '<cmd>Telescope grep_string<CR>', { noremap = true, silent = true, desc = "Grep String Under Cursor" })
-- Telescope live_grep
vim.api.nvim_set_keymap('n', '<leader>g', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true, desc = "Grep String" })
-- Telescope project_grep
vim.api.nvim_set_keymap('n', '<leader>G', '<cmd>lua require("telescope-settings").project_grep()<CR>', { noremap = true, silent = true, desc = "Grep Project String" })
-- Telescope buffers
vim.api.nvim_set_keymap('n', '<leader>b', '<cmd>Telescope buffers<CR>', { noremap = true, silent = true, desc = "Open Buffer" })
-- Telescope spell_suggest
vim.api.nvim_set_keymap('n', '<leader>S', '<cmd>Telescope spell_suggest<CR>', { noremap = true, silent = true, desc = "Spell Suggest" })

return M
