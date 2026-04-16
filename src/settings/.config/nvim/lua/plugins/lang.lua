return {
  {
    "henry-hsieh/riscv-asm-vim",
    ft = "riscv_asm",
    config = function()
      local s = require("config").lang.riscv
      vim.g.riscv_asm_isa = s.isa
      if s.debug then
        vim.g.riscv_asm_debug = true
      end
      if s.all then
        vim.g.riscv_asm_all_enable = true
      end
    end,
  },

  {
    "vhda/verilog_systemverilog.vim",
    ft = "verilog_systemverilog",
    config = function()
      local s = require("config").lang.verilog
      vim.g.verilog_disable_indent_lst = s.disable_indent
      vim.treesitter.language.register("systemverilog", "verilog_systemverilog")
    end,
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons'
    },
    ft = 'markdown',
    cmd = { 'RenderMarkdown' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
}
