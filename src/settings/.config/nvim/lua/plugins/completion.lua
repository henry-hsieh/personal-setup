return {
  {
    'saghen/blink.cmp',
    dependencies = {
      'rafamadriz/friendly-snippets',
      {
        "mikavilpas/blink-ripgrep.nvim",
        version = "*",
      },
      "moyiz/blink-emoji.nvim",
      "folke/sidekick.nvim",
      "folke/lazydev.nvim",
    },
    version = '*',
    build = 'cargo build --release',
    event = 'InsertEnter',
    opts = {
      keymap = {
        preset = "default",
        ["<Tab>"] = {
          "select_next",
          "snippet_forward",
          function()
            return require("sidekick").nes_jump_or_apply()
          end,
          "fallback"
        },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      completion = {
        list = { selection = { preselect = true, auto_insert = true } },
        documentation = { auto_show = true },
      },
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer", "emoji", "ripgrep" },
        providers = {
          lazydev = {
            module = "lazydev.integrations.blink",
            name = "LazyDev",
            score_offset = 100,
          },
          ripgrep = {
            module = "blink-ripgrep",
            name = "Ripgrep",
            opts = {
              backend = {
                use = "gitgrep-or-ripgrep",
              },
            },
          },
          emoji = {
            module = "blink-emoji",
            name = "Emoji",
            score_offset = 15,
            opts = {
              insert = true,
              ---@type string|table|fun():table
              trigger = function()
                return { ":" }
              end,
            },
            should_show_items = function()
              return vim.tbl_contains(
                -- Enable emoji completion only for git commits and markdown.
                -- By default, enabled for all file-types.
                { "gitcommit", "markdown" },
                vim.o.filetype
              )
            end,
          },
        },
      },
    },
    opts_extend = { "sources.default" }
  },
}
