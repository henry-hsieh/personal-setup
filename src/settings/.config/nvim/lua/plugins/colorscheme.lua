return {
  {
    "tinted-theming/tinted-nvim",
    lazy = false,    -- load main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    init = function()
      vim.o.termguicolors = true
    end,
    opts = {
      compile = true,
      capabilities = {
        undercurl = true,
      },
      highlights = {
        overrides = function(colors)
          return {
            FlashLabel        = { fg = colors.base01, bg = colors.base08, bold = false, italic = false },
            FlashMatch        = { fg = colors.base01, bg = colors.base09, bold = false, italic = false },
            FlashCurrent      = { fg = colors.base01, bg = colors.base0D, bold = false, italic = false },
            Folded            = { fg = nil, bg = colors.base01, bold = false, italic = false },
            FoldColumn        = { fg = colors.base03, bg = nil, bold = false, italic = false },
            NonText           = { fg = colors.base03, bg = nil, bold = false, italic = false },
            SnacksIndent      = { fg = colors.base02, bg = nil, bold = false, italic = false },
            SnacksIndentScope = { fg = colors.base0C, bg = nil, bold = false, italic = false },
            StatusLine        = { link = "lualine_c_normal" },
            DiffAdd           = { fg = "green" },
            DiffChange        = { fg = "orange" },
            DiffDelete        = { fg = "red" },
            DiffText          = { fg = "blue" },
            GitSignsAdd       = { link = "DiffAdd" },
            GitSignsChange    = { link = "DiffChange" },
            GitSignsDelete    = { link = "DiffDelete" },
          }
        end,
      },
      selector = {
        enabled = true,
      },
    },
  },
}
