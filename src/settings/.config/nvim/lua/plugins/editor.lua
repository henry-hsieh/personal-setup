return {
  {
    'numToStr/Comment.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    opts = function()
      local ft = require('Comment.ft')
      local m = require("config").editor.comment

      ft({ 'verilog', 'verilog_systemverilog' }, ft.get('c'))

      return {
        ---LHS of toggle mappings in NORMAL mode
        toggler = {
          ---Line-comment toggle keymap
          line = m.toggle_line,
          ---Block-comment toggle keymap
          block = m.toggle_block,
        },
        ---LHS of operator-pending mappings in NORMAL and VISUAL mode
        opleader = {
          ---Line-comment keymap
          line = m.opleader_line,
          ---Block-comment keymap
          block = m.opleader_block,
        },
        ---LHS of extra mappings
        extra = {
          ---Add comment on the line above
          above = m.add_above,
          ---Add comment on the line below
          below = m.add_below,
          ---Add comment at the end of line
          eol = m.add_eol,
        },
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      }

    end,
    keys = function()
      local m = require("config").editor.comment
      local keys = {}
      for _, key in pairs(m) do
        table.insert(keys, key)
      end

      return keys
    end,
  },
  {
    "TheNoeTrevino/haunt.nvim",
    ---@class HauntConfig
    opts = {
      sign = "󱙝",
      sign_hl = "DiagnosticInfo",
      virt_text_hl = "HauntAnnotation",
      annotation_prefix = " 󰆉 ",
      line_hl = nil,
      virt_text_pos = "eol",
      data_dir = nil,
      picker_keys = {
        delete = { key = "d", mode = { "n" } },
        edit_annotation = { key = "a", mode = { "n" } },
      },
    },
    keys = {
      -- annotations
      { "<space>ha", function() require("haunt.api").annotate() end,                                desc = "Annotate" },
      { "<space>ht", function() require("haunt.api").toggle_annotation() end,                       desc = "Toggle annotation" },
      { "<space>hT", function() require("haunt.api").toggle_all_lines() end,                        desc = "Toggle all annotations" },
      { "<space>hd", function() require("haunt.api").delete() end,                                  desc = "Delete annotation" },
      { "<space>hD", function() require("haunt.api").clear_all() end,                               desc = "Delete all annotations" },
      -- move
      { "[a",        function() require("haunt.api").prev() end,                                    desc = "Previous annotation" },
      { "]a",        function() require("haunt.api").next() end,                                    desc = "Next annotation" },
      -- picker
      { "<space>hl", function() require("haunt.picker").show() end,                                 desc = "Show pickers" },
      -- quickfix
      { "<space>hq", function() require("haunt.api").to_quickfix() end,                             desc = "Show quickfix" },
      { "<space>hQ", function() require("haunt.api").to_quickfix({ current_buffer = true }) end,    desc = "Show quickfix of current buffer" },
      -- yank
      { "<space>hy", function() require("haunt.api").yank_locations() end,                          desc = "Yank locations" },
      { "<space>hY", function() require("haunt.api").yank_locations({ current_buffer = true }) end, desc = "Yank locations of current buffer" },
    }
  },
}
