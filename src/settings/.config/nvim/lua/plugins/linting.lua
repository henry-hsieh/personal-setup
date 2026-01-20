return {
  -- Reference LazyVim configurations for nvim-lint
  {
    "mfussenegger/nvim-lint",
    event = "LazyFile",
    opts = {
      -- Event to trigger linters
      events = { "BufWritePost", "BufReadPost", "InsertLeave", "TextChanged" },
      linters_by_ft = {
        -- Use the "*" filetype to run linters on all filetypes.
        -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
        ['*'] = { 'genlint' },
      },
      -- LazyVim extension to easily override linter options
      -- or add custom linters.
      ---@type table<string,table>
      linters = {
        genlint = {
          cmd = 'genlint',
          stdin = true,
          args = (function()
            local base_args = { '-s', '-f', 'json' }
            local disable_rules = require("config").lint.genlint.disable_rules
            if disable_rules ~= '' then
              return vim.fn.extend(base_args, { '-d', disable_rules })
            end
            return base_args
          end)(),
          stream = 'stdout',
          parser = function(output, bufnr)
            local decoded = vim.json.decode(output) or {}
            local result = {}
            local buf_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
            local genlint_severity = {
              error = vim.diagnostic.severity.ERROR,
              warning = vim.diagnostic.severity.WARN,
              information = vim.diagnostic.severity.INFO,
            }
            for _, diagnostic in ipairs(decoded or {}) do
              local result_diagnostic = {
                message = string.format("[%s] %s", diagnostic.code, diagnostic.message),
                lnum = diagnostic.lnum,
                end_lnum = diagnostic.end_lnum,
                col = diagnostic.col,
                end_col = diagnostic.end_col and (diagnostic.end_col + 1) or nil,
                source = "Genlint",
                severity = genlint_severity[diagnostic.severity],
                filename = buf_path,
              }
              table.insert(result, result_diagnostic)
            end
            return result
          end,
        },
      },
    },
    config = function(_, opts)
      if not require("config").features.linting then
        return
      end

      local M = {}

      local lint = require("lint")
      for name, linter in pairs(opts.linters) do
        if type(linter) == "table" and type(lint.linters[name]) == "table" then
          lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
          if type(linter.prepend_args) == "table" then
            lint.linters[name].args = lint.linters[name].args or {}
            vim.list_extend(lint.linters[name].args, linter.prepend_args)
          end
        else
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft

      function M.debounce(ms, fn)
        local timer = vim.uv.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      local disabled_filetypes = {
        help = true,
        NvimTree = true,
        lazy = true,
        TelescopePrompt = true,
        mason = true,
        noice = true,
        qf = true,
        checkhealth = true,
        snacks_dashboard = true,
        snacks_picker_input = true,
        snacks_picker_list = true,
        snacks_layout_box = true,
        snacks_input = true,
        snacks_notif = true,
        snacks_notif_history = true,
        snacks_terminal = true,
        sidekick_terminal = true,
        ["blink-cmp-menu"] = true,
        ["blink-cmp-signature"] = true,
        ["blink-cmp-documentation"] = true,
        trouble = true,
        bigfile = true,
        yazi = true,
        ["codediff-explorer"] = true,
      }

      function M.lint()
        -- Ignore disabled filetypes
        local ft = vim.bo.filetype
        if disabled_filetypes[ft] then
          return
        end
        -- Use nvim-lint's logic first:
        -- * checks if linters exist for the full filetype first
        -- * otherwise will split filetype by "." and add all those linters
        -- * this differs from conform.nvim which only uses the first filetype that has a formatter
        local names = lint._resolve_linter_by_ft(ft)

        -- Create a copy of the names table to avoid modifying the original.
        names = vim.list_extend({}, names)

        -- Add fallback linters.
        if #names == 0 then
          vim.list_extend(names, lint.linters_by_ft["_"] or {})
        end

        -- Add global linters.
        vim.list_extend(names, lint.linters_by_ft["*"] or {})

        -- Filter out linters that don't exist or don't match the condition.
        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then
            Snacks.notifier("Linter not found: " .. name, "warn", { title = "nvim-lint" })
          end
          return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
        end, names)

        -- Run linters.
        if #names > 0 then
          lint.try_lint(names)
        end
      end

      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = M.debounce(100, M.lint),
      })
    end,
  },
}
