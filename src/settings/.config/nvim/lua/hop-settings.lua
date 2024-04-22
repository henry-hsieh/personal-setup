-- hop-settings.lua
local M = {}

-- remap f, F, t, T behavior to Hop
vim.api.nvim_set_keymap('', 'f', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>", {})
vim.api.nvim_set_keymap('', 'F', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>", {})
vim.api.nvim_set_keymap('', 't', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })<cr>", {})
vim.api.nvim_set_keymap('', 'T', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = -1 })<cr>", {})
-- map HopWord
vim.api.nvim_set_keymap('', '<leader>w', "<cmd>HopWord<cr>", {})
-- map HopWORD
vim.api.nvim_set_keymap('', '<leader>W', "<cmd>HopWORD<cr>", {})
-- map HopWordEnd
vim.api.nvim_set_keymap('', '<leader>e', "<cmd>HopWordEnd<cr>", {})
-- map HopWORDEnd
vim.api.nvim_set_keymap('', '<leader>E', "<cmd>HopWORDEnd<cr>", {})
-- map HopLineStart
vim.api.nvim_set_keymap('', '<leader>l', "<cmd>HopLineStart<cr>", {})
-- map HopLine
vim.api.nvim_set_keymap('', '<leader>L', "<cmd>HopLine<cr>", {})
-- map HopChar1
vim.api.nvim_set_keymap('', '<leader>c', "<cmd>HopChar1<cr>", {})
-- map HopChar2
vim.api.nvim_set_keymap('', '<leader>C', "<cmd>HopChar2<cr>", {})
-- map HopPattern
vim.api.nvim_set_keymap('', '<leader>/', "<cmd>HopPattern<cr>", {})

-- HopWORD: the sequence of non-blank characters start
function M.hint_WORD()
  local pat = [[\(^\|\s\+\)\zs\S\+\ze]]
  local opts = require('hop').opts
  require('hop').hint_with_regex(require('hop.jump_regex').regex_by_case_searching(pat, false, opts), opts)
end
vim.api.nvim_create_user_command('HopWORD', "lua require('hop-settings').hint_WORD()", {})
-- HopWordEnd: the word end
function M.hint_word_end()
  require('hop').hint_words({ hint_position = require'hop.hint'.HintPosition.END })
end
vim.api.nvim_create_user_command('HopWordEnd', "lua require('hop-settings').hint_word_end()", {})
-- HopWORDEnd: the sequence of non-blank characters end
function M.hint_WORD_end()
  local pat = [[\(^\|\s\+\)\zs\S\+\ze]]
  local opts = require('hop').opts
  opts.hint_position = require'hop.hint'.HintPosition.END
  require('hop').hint_with_regex(require('hop.jump_regex').regex_by_case_searching(pat, false, opts), opts)
end
vim.api.nvim_create_user_command('HopWORDEnd', "lua require('hop-settings').hint_WORD_end()", {})

return M
