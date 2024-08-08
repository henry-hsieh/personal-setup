local plugin_settings = {
  telescope = {
    mappings = {
      close = "<C-x>",
      horizontal_split = "<C-s>",
      vertical_split = "<C-v>",
      scroll_up = "<C-b>",
      scroll_down = "<C-f>",
      move_up = "<C-k>",
      move_down = "<C-j>",
      preview_up = "<C-Up>",
      preview_down = "<C-Down>",
    },
  },
  nvim_tree = {
    mappings = {
      horizontal_split = "<C-s>",
      vertical_split = "<C-v>",
      toggle = "<space>e",
    }
  },
  nvim_lspconfig = {
    mappings = {
      diagnostic = {
        open_float = "<space>d",
        goto_prev = "[d",
        goto_next = "]d",
        goto_warn_prev = "[w",
        goto_warn_next = "]w",
        goto_err_prev = "[e",
        goto_err_next = "]e",
        open_list = "<space>q",
      },
      buffer = {
        goto_declaration = "gD",
        goto_definition = "gd",
        goto_implementation = "gi",
        goto_reference = "gr",
        hover = "K",
        signature_help = "<C-k>",
        add_workspace_folder = "<space>wa",
        remove_workspace_folder = "<space>wr",
        list_workspace_folder = "<space>wl",
        type_definition = "<space>D",
        rename = "<space>r",
        code_action = "<space>a",
        format = "<space>f",
      }
    },
  },
  gitsigns = {
    mappings = {
      next_hunk = "]h",
      prev_hunk = "[h",
      last_hunk = "]H",
      first_hunk = "[H",
      stage_hunk = "<leader>hs",
      reset_hunk = "<leader>hr",
      stage_buffer = "<leader>hS",
      reset_buffer = "<leader>hR",
      undo_stage_hunk = "<leader>hu",
      preview_hunk = "<leader>hp",
      blame_hunk = "<leader>hb",
      toggle_blame = "<leader>tb",
      diff_hunk = "<leader>hd",
      toggle_deleted = "<leader>td",
    },
  },
  nvim_cmp = {
    mappings = {
      next_item = "<Tab>",
      prev_item = "<S-Tab>",
      scroll_up = "<C-b>",
      scroll_down = "<C-f>",
      abort = "<C-e>",
      confirm = "<CR>",
    },
  },
  truezen = {
    mappings = {
      ataraxis = "<C-w>a",
      focus = "<C-w>z",
      minimalist = "<C-w>m",
    },
  },
  riscv_asm_vim = {
    settings = {
      isa = "RVA23S64",
      debug = false,
      all = true,
    },
  },
  verilog_systemverilog = {
    settings = {
      disable_indent = "preproc,eos,standalone",
    },
  },
  comment = {
    mappings = {
      toggle_line = "gcc",
      toggle_block = "gbc",
      opleader_line = "gc",
      opleader_block = "gb",
      add_above = "gcO",
      add_below = "gco",
      add_eol = "gcA",
    },
  },
}

return plugin_settings
