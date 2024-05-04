-------------------------
-- Neovim Setting
-------------------------
-- Shell
vim.o.shell = "bash"
vim.env.SHELL = "bash"

-- Clipboard
vim.o.clipboard = "unnamed,unnamedplus"

-- Leader
if vim.inspect('g:mapleader') ~= nil then
  vim.g.mapleader = ','
end

-- Tabstop
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- Toggle between tab stops of 2 and 4
function ToggleTabstop()
  if vim.bo.tabstop == 2 then
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
    vim.bo.shiftwidth = 4
    print("Tabstop set to 4 spaces")
  else
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
    vim.bo.shiftwidth = 2
    print("Tabstop set to 2 spaces")
  end
end

-- Map the ToggleTabstop to a key
vim.api.nvim_set_keymap('n', '<leader><Tab>', [[:lua ToggleTabstop()<CR>]], { noremap = true, silent = true })

-- Mouse
vim.o.mouse = "a"

-- Color
vim.o.termguicolors = true

-- Map
vim.api.nvim_set_keymap('t', '<Esc><Esc>', '<C-\\><C-n>', { noremap = true, silent = true })
