-- hop-settings.lua
local M = {}
local opts = {}

-- remap f, F, t, T behavior to Hop
vim.api.nvim_set_keymap('', 'f', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>", {})
vim.api.nvim_set_keymap('', 'F', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>", {})
vim.api.nvim_set_keymap('', 't', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, inclusive_jump = true })<cr>", {})
vim.api.nvim_set_keymap('', 'T', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, inclusive_jump = true })<cr>", {})
-- map HopWord
vim.api.nvim_set_keymap('', ',w', "<cmd>HopWord<cr>", {})
-- map HopLineStart
vim.api.nvim_set_keymap('', ',l', "<cmd>HopLineStart<cr>", {})
-- map HopLine
vim.api.nvim_set_keymap('', ',L', "<cmd>HopLine<cr>", {})
-- map HopChar1
vim.api.nvim_set_keymap('', ',c', "<cmd>HopChar1<cr>", {})
-- map HopChar2
vim.api.nvim_set_keymap('', ',C', "<cmd>HopChar2<cr>", {})
-- map HopPattern
vim.api.nvim_set_keymap('', ',/', "<cmd>HopPattern<cr>", {})
-- map custom non-space word start jump
function M.regex_by_non_space_word_start()
    local pat = vim.regex([[\(^\|\s\+\)\zs\S\+\ze]])
    return {
        oneshot = false,
        match = function(s)
            return pat:match_str(s)
        end
    }
end
vim.api.nvim_set_keymap('', ',W', "<cmd>lua require'hop'.hint_with(require'hop.jump_target'.jump_targets_by_scanning_lines(require'hop-settings'.regex_by_non_space_word_start()))<cr>", {})
-- map custom word end jump
function M.regex_by_word_end()
    local pat = vim.regex([[\zs\w\ze\>]])
    return {
        oneshot = false,
        match = function(s)
            return pat:match_str(s)
        end
    }
end
vim.api.nvim_set_keymap('', ',e', "<cmd>lua require'hop'.hint_with(require'hop.jump_target'.jump_targets_by_scanning_lines(require'hop-settings'.regex_by_word_end()))<cr>", {})
-- map custom non-space word end jump
function M.regex_by_non_space_word_end()
    local pat = vim.regex([[\zs\S\ze\($\|\s\+\)]])
    return {
        oneshot = false,
        match = function(s)
            return pat:match_str(s)
        end
    }
end
vim.api.nvim_set_keymap('', ',E', "<cmd>lua require'hop'.hint_with(require'hop.jump_target'.jump_targets_by_scanning_lines(require'hop-settings'.regex_by_non_space_word_end()))<cr>", {})

return M
