return {
  {
    "tinted-theming/tinted-nvim",
    lazy = false,    -- load main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    init = function()
      vim.o.termguicolors = true
    end,
    config = function()
      -- require manual setup because the module name is not conventional
      local tinted = require('tinted-colorscheme')
      tinted.setup(nil, {
        supports = {
          tinted_shell = true,
          live_reload = true,
        },
      })
      vim.api.nvim_create_autocmd("User", {
        pattern = "TintedColorsPost",
        callback = function()
          -- Do things whenever the theme changes.
          local colors = require("tinted-colorscheme").colors
          if colors then
            vim.api.nvim_set_hl(0, "FlashLabel",     { fg = colors.base06, bg = colors.base08, bold = false, italic = false })
            vim.api.nvim_set_hl(0, "FlashMatch",     { fg = colors.base06, bg = colors.base0D, bold = false, italic = false })
            vim.api.nvim_set_hl(0, "Folded",
              { fg = nil, bg = colors.base01, bold = false, italic = false })
            vim.api.nvim_set_hl(0, "FoldColumn",
              { fg = colors.base03, bg = nil, bold = false, italic = false })
            vim.api.nvim_set_hl(0, "SnacksIndent",
              { fg = colors.base02, bg = nil, bold = false, italic = false })
            vim.api.nvim_set_hl(0, "SnacksIndentScope",
              { fg = colors.base0C, bg = nil, bold = false, italic = false })
            vim.api.nvim_set_hl(0, "StatusLine", { link = "lualine_c_normal" })
          end
        end,
      })
      vim.cmd.doautocmd("User TintedColorsPost")
    end,
  },
}
