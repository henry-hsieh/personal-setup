return {
  plugins = {
    { name = "lazy.nvim", modes = { "load", "health" } },
    { name = "nvim-treesitter", modes = { "load", "health" } },
    { name = "nvim-ufo", modes = { "load", "call" }, call = { fn = "ufo.closeAllFolds" } },
    { name = "mason.nvim", modes = { "load", "health" } },
    { name = "gitsigns.nvim", modes = { "load", "call" }, call = { fn = "gitsigns.actions.reset_buffer" } },
    { name = "blink.cmp", modes = { "load", "health" } },
    { name = "lualine.nvim", modes = { "load", "call" }, call = { fn = "lualine.refresh" } },
    { name = "Comment.nvim", modes = { "load", "health" } },
    { name = "which-key.nvim", modes = { "load", "health" } },
    { name = "tabby.nvim", modes = { "load", "call" }, call = { fn = "tabby.update" } },
    { name = "noice.nvim", modes = { "load", "health" } },
    { name = "lazydev.nvim", modes = { "load", "health", "trigger" }, trigger = { ft = "lua" } },
    { name = "flash.nvim", modes = { "load", "call" }, call = { fn = "flash.toggle" } },
    { name = "snacks.nvim", modes = { "load", "health" } },
    { name = "tinted-nvim", modes = { "load", "health" } },
    { name = "trouble.nvim", modes = { "load", "call" }, call = { fn = "trouble.open", args = { { mode = "qflist" } } } },
    { name = "yazi.nvim", modes = { "load", "health" } },
    { name = "nvim-lint", modes = { "load", "call" }, call = { fn = "lint.try_lint" } },
    { name = "sidekick.nvim", modes = { "load", "health" } },
    { name = "riscv-asm-vim", modes = { "load", "vim-plugin", "trigger" }, vim_plugin = { exists = "*GetRiscvIndent", cmd = "let dummy=GetRiscvIndent()" }, trigger = { ft = "riscv_asm" } },
    { name = "verilog_systemverilog.vim", modes = { "load", "vim-plugin", "trigger" }, vim_plugin = { exists = "*GetVerilogSystemVerilogIndent", cmd = "let dummy=GetVerilogSystemVerilogIndent()" }, trigger = { ft = "verilog_systemverilog" } },
  },
  config_modules = {
    "config.options",
    "config.init",
    "utils",
  },
  ts_parsers = {
    "lua", "vim", "vimdoc", "query", "python", "bash", "json", "yaml", "markdown"
  }
}
