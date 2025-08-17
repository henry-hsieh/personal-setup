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
vim.o.shiftround = true

-- Wrap
vim.o.wrap = false

-- Mouse
vim.o.mouse = "a"

-- Color
vim.o.termguicolors = true

-- Scroll
vim.o.scrolloff = 4

-- Sidecolumn
vim.o.signcolumn = "yes"

-- Showmode
vim.o.showmode = false

-- Map
vim.keymap.set('t', '<C-q>', '<C-\\><C-n>', { desc = "Enter Normal Mode", noremap = true, silent = true })
vim.keymap.set({'n', 'v'}, '<C-q>', '<cmd>close<cr>', { desc = "Close Window", noremap = true, silent = true })
vim.keymap.set("v", "<", "<gv", { desc = "Shift Left", noremap = true})
vim.keymap.set("v", ">", ">gv", { desc = "Shift Right", noremap = true})

-- Grep
vim.o.grepformat = "%f:%l:%c:%m"
vim.o.grepprg = "rg --vimgrep"

-- Undofile
vim.o.undofile = true
vim.o.undolevels = 10000

-- Updatetime
vim.o.updatetime = 200

-- Autoread
vim.o.autoread = true

-- Autowrite
vim.o.autowrite = true

-- Tab
vim.keymap.set("n", "<space><tab>n", "<cmd>tabnew | NvimTreeOpen<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<space><tab>e", "<cmd>tabe %<cr>", { desc = "New Tab (Current Buffer)" })
vim.keymap.set("n", "<space><tab>q", "<cmd>tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "]<tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "[<tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Buffer
vim.keymap.set("n", "<space>bD", "<cmd>bdelete<cr>", { desc = "Delete Buffer and Window" })
vim.keymap.set("n", "<space>bn", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<space>bp", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })

-- Diff
vim.keymap.set("n", "]D", "<cmd>lua vim.cmd.normal({']c', bang = true})<cr>", { desc = "Next Diff" })
vim.keymap.set("n", "[D", "<cmd>lua vim.cmd.normal({'[c', bang = true})<cr>", { desc = "Previous Diff" })

-- Clear search with <esc>
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and Clear hlsearch" })
