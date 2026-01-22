local M = {}

--------------------------------------------------------------------------------
-- Feature Toggles (easy on/off switches)
--------------------------------------------------------------------------------
M.features = {
  copilot = true,           -- Enable Copilot/AI suggestions
  ai_cli = true,            -- Enable AI CLI (sidekick)
  linting = true,           -- Enable nvim-lint
  format_on_save = false,   -- Auto-format on save
}

--------------------------------------------------------------------------------
-- LSP Configuration
--------------------------------------------------------------------------------
M.lsp = {
  -- LSP servers to install via Mason
  ensure_installed = {
    "clangd",
    "verible",
    "vimls",
    "pyright",
    "bashls",
    "ts_ls",
    "jsonls",
    "copilot",
  },

  -- Diagnostic keymaps
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
    -- Buffer mappings
    buffer = {
      signature_help = "<C-k>",
      add_workspace_folder = "<space>wa",
      remove_workspace_folder = "<space>wr",
      list_workspace_folder = "<space>wl",
      type_definition = "<space>D",
      rename = "<space>r",
      code_action = "<space>a",
      format = "<space>f",
    },
  },
}

--------------------------------------------------------------------------------
-- Git (gitsigns)
--------------------------------------------------------------------------------
M.git = {
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
}

--------------------------------------------------------------------------------
-- Editor (Comment.nvim, etc.)
--------------------------------------------------------------------------------
M.editor = {
  comment = {
    toggle_line = "gcc",
    toggle_block = "gbc",
    opleader_line = "gc",
    opleader_block = "gb",
    add_above = "gcO",
    add_below = "gco",
    add_eol = "gcA",
  },
}

--------------------------------------------------------------------------------
-- Linting
--------------------------------------------------------------------------------
M.lint = {
  genlint = {
    disable_rules = "long-line,consecutive-blank,final-newline",
  },
}

--------------------------------------------------------------------------------
-- Language-specific settings
--------------------------------------------------------------------------------
M.lang = {
  riscv = {
    isa = "RVA23S64",
    debug = false,
    all = true,
  },
  verilog = {
    disable_indent = "preproc,eos,standalone",
  },
}

--------------------------------------------------------------------------------
-- Merge with custom config (if exists)
--------------------------------------------------------------------------------
return M
