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
vim.api.nvim_set_keymap('n', '<leader>t<Tab>', [[:lua ToggleTabstop()<CR>]], { desc = "Toggle Tabstop Width", noremap = true, silent = true })

-- Map the Toggle Wrap to a key
vim.api.nvim_set_keymap('n', '<leader>tw', [[:set wrap!<CR>]], { desc = "Toggle Wrap", noremap = true, silent = true })

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
local function reload_all_buffers_in_tab()
    local tab_buffers = vim.fn.tabpagebuflist(vim.fn.tabpagenr())  -- Get buf list of current tab
    for _, buf in ipairs(tab_buffers) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
            vim.api.nvim_buf_call(buf, function()
                vim.cmd("checktime")
            end)
        end
    end
    vim.cmd("redraw!")
end

vim.api.nvim_create_autocmd("TermClose", {
    pattern = "*",
    callback = reload_all_buffers_in_tab,
})

-- Tab
vim.keymap.set("n", "<space><tab>n", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<space><tab>q", "<cmd>tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "]<tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "[<tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Buffer
vim.keymap.set("n", "<space>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })
vim.keymap.set("n", "<space>bn", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<space>bp", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })

-- Clear search with <esc>
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and Clear hlsearch" })
