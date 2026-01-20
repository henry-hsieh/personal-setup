return {
  {
    "folke/sidekick.nvim",
    init = function()
      vim.g.sidekick_nes = require("config").features.copilot
    end,
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
      },
      {
        "nvim-lualine/lualine.nvim",
        opts = function(_, opts)
          opts.sections = opts.sections or {}
          opts.sections.lualine_x = opts.sections.lualine_x or {}

          -- Copilot status
          table.insert(opts.sections.lualine_x, 1, {
            function()
              return " "
            end,
            color = function()
              local status = require("sidekick.status").get()
              if status then
                return status.kind == "Error" and "DiagnosticError" or status.busy and "DiagnosticWarn" or "DiagnosticHint"
              end
            end,
            cond = function()
              local status = require("sidekick.status")
              return status.get() ~= nil
            end,
          })

          -- CLI session status
          table.insert(opts.sections.lualine_x, 1, {
            function()
              local status = require("sidekick.status").cli()
              return " " .. (#status > 1 and " " .. #status or "")
            end,
            color = function()
              return "DiagnosticHint"
            end,
            cond = function()
              return #require("sidekick.status").cli() > 0
            end,
          })
        end,
      }
    },
    opts = {
      -- add any options here
      cli = {
        mux = {
          backend = "tmux",
          enabled = require("config").features.ai_cli,
        },
        win = {
          keys = {
            prompt = { "<a-p>", "prompt", mode = "t", desc = "insert prompt or context" },
          },
        },
      },
      copilot = {
        status = {
          enabled = require("config").features.copilot,
        },
      },
    },
    keys = {
      {
        "<tab>",
        function()
          -- if there is a next edit, jump to it, otherwise apply it if any
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>" -- fallback to normal tab
          end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<c-.>",
        function() require("sidekick.cli").toggle() end,
        desc = "Sidekick Toggle",
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>aa",
        function() require("sidekick.cli").toggle() end,
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>as",
        function() require("sidekick.cli").select({ filter = { installed = true } }) end,
        desc = "Select Installed CLI",
      },
      {
        "<leader>ad",
        function() require("sidekick.cli").close() end,
        desc = "Detach a CLI Session",
      },
      {
        "<leader>at",
        function() require("sidekick.cli").send({ msg = "{this}" }) end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        "<leader>af",
        function() require("sidekick.cli").send({ msg = "{file}" }) end,
        desc = "Send File",
      },
      {
        "<leader>av",
        function() require("sidekick.cli").send({ msg = "{selection}" }) end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>ap",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
    },
  },
}
