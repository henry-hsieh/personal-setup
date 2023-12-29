-------------------------
-- Neovim Setting
-------------------------
-- Shell
vim.o.shell = "bash"
vim.env.SHELL = "bash"

-- CC
if vim.fn.executable('musl-gcc') == 1 then
    vim.env.CC = 'musl-gcc'
else
    vim.env.CC = 'gcc'
end

-- Clipboard
vim.o.clipboard = "unnamed,unnamedplus"

-- Tabstop
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
vim.bo.shiftwidth = 2
vim.bo.expandtab = true

-- Toggle between tab stops of 2 and 4
function toggle_tabstop()
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

-- Map the toggle_tabstop to a key
vim.api.nvim_set_keymap('n', ',<Tab>', [[:lua toggle_tabstop()<CR>]], { noremap = true, silent = true })

-- Mouse
vim.o.mouse = "a"

-- Color
vim.o.termguicolors = true
