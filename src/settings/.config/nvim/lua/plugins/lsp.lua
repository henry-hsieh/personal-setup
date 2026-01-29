return {
  {
    'mason-org/mason-lspconfig.nvim',
    event = 'BufReadPre',
    dependencies = {
      {
        'henry-hsieh/mason.nvim',
        branch = 'feat-linker-exec-relative',
        opts = {}
      },
      'neovim/nvim-lspconfig',
    },
    opts = function()
      return {
        ensure_installed = require("config").lsp.ensure_installed,
      }
    end,
  },

  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = {
      'mason-org/mason-lspconfig.nvim',
    },
    opts = function()
      return {
        ensure_installed = require("config").lsp.ensure_installed,
      }
    end,
    cmd = {
      'MasonToolsInstall',
      'MasonToolsInstallSync',
      'MasonToolsUpdate',
      'MasonToolsUpdateSync',
      'MasonToolsClean',
    },
  },

  {
    'neovim/nvim-lspconfig',
    event = 'BufReadPre',
    keys = function()
      local config = require("config")
      -- Global mappings.
      local md = config.lsp.mappings.diagnostic
      local mb = config.lsp.mappings.buffer

      ---@param next boolean
      ---@param severity? string
      ---@return function
      local diagnostic_jump = function(next, severity)
        local severity_num = severity and vim.diagnostic.severity[severity] or nil
        return function()
          vim.diagnostic.jump({
            count = next and 1 or -1,
            severity = severity_num
          })
        end
      end

      return {
        { md.open_float,     mode = { "n" },      vim.diagnostic.open_float,                           desc = "Open Diagnostic Message" },
        { md.goto_next,      mode = { "n" },      diagnostic_jump(true),                               desc = "Next Diagnostic" },
        { md.goto_prev,      mode = { "n" },      diagnostic_jump(false),                              desc = "Prev Diagnostic" },
        { md.goto_warn_next, mode = { "n" },      diagnostic_jump(true, "WARN"),                       desc = "Next Warning" },
        { md.goto_warn_prev, mode = { "n" },      diagnostic_jump(false, "WARN"),                      desc = "Prev Warning" },
        { md.goto_err_next,  mode = { "n" },      diagnostic_jump(true, "ERROR"),                      desc = "Next Error" },
        { md.goto_err_prev,  mode = { "n" },      diagnostic_jump(false, "ERROR"),                     desc = "Prev Error" },
        { md.open_list,      mode = { "n" },      vim.diagnostic.setloclist,                           desc = "Open Diagnostic List" },
        { mb.signature_help, mode = { 'n', 'i' }, vim.lsp.buf.signature_help,                          desc = "Signature Help" },
        { mb.rename,         mode = { 'n' },      vim.lsp.buf.rename,                                  desc = "Rename" },
        { mb.code_action,    mode = { 'n', 'v' }, vim.lsp.buf.code_action,                             desc = "Code Action" },
        { mb.format,         mode = { 'n', 'v' }, function() vim.lsp.buf.format({ async = true }) end, desc = "Format" },
      }
    end,
    config = function()
      local utils = require("utils")
      local config = require("config")

      -- LSP log level
      vim.lsp.set_log_level(config.lsp.log_level)

      -- Appearance
      vim.diagnostic.config({
        virtual_text = true,
        virtual_lines = { current_line = true },
        underline = true,
        update_in_insert = false,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.INFO] = '',
            [vim.diagnostic.severity.HINT] = '',
          },
        },
        float = {
          border = 'rounded',
        },
      })

      --- auto hide virtual text when cursor is on the line
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'DiagnosticChanged' }, {
        group = vim.api.nvim_create_augroup('diagnostic_virt_text_hide', {}),
        callback = function(ev)
          local lnum, _ = unpack(vim.api.nvim_win_get_cursor(0))
          lnum = lnum - 1 -- need 0-based index

          local hidden_lnum = vim.b[ev.buf].diagnostic_hidden_lnum
          if hidden_lnum and hidden_lnum ~= lnum then
            vim.b[ev.buf].diagnostic_hidden_lnum = nil
            -- display all the decorations if the current line changed
            vim.diagnostic.show(nil, ev.buf)
          end

          for _, namespace in pairs(vim.diagnostic.get_namespaces()) do
            local ns_id = namespace.user_data.virt_text_ns
            if ns_id then
              local extmarks = vim.api.nvim_buf_get_extmarks(ev.buf, ns_id, { lnum, 0 }, { lnum, -1 }, {})
              for _, extmark in pairs(extmarks) do
                local id = extmark[1]
                vim.api.nvim_buf_del_extmark(ev.buf, ns_id, id)
              end

              if extmarks and not vim.b[ev.buf].diagnostic_hidden_lnum then
                vim.b[ev.buf].diagnostic_hidden_lnum = lnum
              end
            end
          end
        end,
      })

      -- LSP configuration
      --- harper-ls
      local harper_lspconfig = vim.lsp.config["harper_ls"] or {}
      harper_lspconfig.filetypes = harper_lspconfig.filetypes or {}
      local harper_configs = {
        prose = {
          filetypes = config.lsp.harper.prose.filetypes,
          grammar = true,
        },
        code = {
          filetypes = vim.tbl_filter(function(ft)
            return not vim.tbl_contains(config.lsp.harper.prose.filetypes, ft)
          end, utils.merge_unique_list(harper_lspconfig.filetypes, config.lsp.harper.code.filetypes)),
          grammar = false,
        },
      }

      for name, harper_config in pairs(harper_configs) do
        local new_harper_lspconfig = vim.tbl_deep_extend("force", harper_lspconfig, {
          filetypes = harper_config.filetypes,
          settings = {
            ["harper-ls"] = {
              linters = {
                SentenceCapitalization = harper_config.grammar,
                SpellCheck = harper_config.grammar,
                OrthographicConsistency = harper_config.grammar,
                SplitWords = harper_config.grammar,
                ExpandStandardInputAndOutput = harper_config.grammar,
              },
            },
          },
        })
        vim.lsp.config("harper_ls_" .. name, new_harper_lspconfig)
        vim.lsp.enable("harper_ls_" .. name, config.lsp.harper[name].enable)
      end

      --- rust-analyzer
      vim.lsp.config("rust_analyzer", {
        settings = {
          ['rust-analyzer'] = {
            diagnostics = {
              enable = true;
            },
            checkOnSave = {
              command = "clippy",
            },
          }
        }
      })
      --- lua-language-server
      -- Use `lua/` directory to detect roots of Neovim plugins and configurations
      vim.lsp.config("lua_ls", {
        root_markers = utils.extend_lsp_config_list("lua_ls", "root_markers", "lua/")
      })
      --- slang-server
      vim.lsp.config("slang-server", {
        cmd = { "slang-server" },
        root_markers = utils.extend_lsp_config_list("slang-server", "root_markers", { ".slang/", ".git" }),
        filetypes = utils.extend_lsp_config_list("slang-server", "filetypes", { "verilog", "systemverilog", "verilog_systemverilog" }),
      })
      --- verible
      vim.lsp.config("verible", {
        cmd = { 'verible-verilog-ls', '--rules_config_search', '--push_diagnostic_notifications=false' },
        root_markers = utils.extend_lsp_config_list("verible", "root_markers", "verible.filelist"),
        filetypes = utils.extend_lsp_config_list("verible", "filetypes", "verilog_systemverilog"),
      })

      -- Enable all listed LSPs
      vim.lsp.enable(config.lsp.enable)
    end,
  },

  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
        { path = "snacks.nvim",        words = { "Snacks" } },
      },
    },
  },

  { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
}
