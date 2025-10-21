----------------------------
-- Plugin Manager: lazy.nvim
----------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- LSP list
local ensure_lsp = {
  "lua_ls",
  "clangd",
  "svlangserver",
  "verible",
  "vimls",
  "pyright",
  "harper_ls",
  "bashls",
  "ts_ls",
  "jsonls",
}

local plugin_settings = require("plugin-settings")
require("lazy").setup({
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local opts = require("config.treesitter")
      local ts_query = vim.treesitter.query
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { '*' },
        callback = function(args)
          local langs = (function(v)
            return v == nil and {} or (type(v) == "string" and { v } or v)
          end)(vim.treesitter.language.get_lang(vim.bo.filetype))
          for _, lang in ipairs(langs) do
            if vim.treesitter.language.add(lang) and opts[lang] and opts[lang].enable then
              if opts[lang].highlight then
                vim.treesitter.start(args.buf, lang)
              end
              if opts[lang].fold then
                vim.wo.foldmethod = 'expr'
                vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
              end
              if opts[lang].indent and ts_query.get(lang, 'indents') then
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
              end
            end
          end
        end,
      })
    end
  },

  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async',
      'nvim-treesitter/nvim-treesitter',
      {
        "luukvbaal/statuscol.nvim",
        opts = function()
          local builtin = require("statuscol.builtin")
          return {
            relculright = true,
            segments = {
              { text = { builtin.foldfunc },      click = "v:lua.ScFa" },
              { text = { "%s" },                  click = "v:lua.ScSa" },
              { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" }
            }
          }
        end,
      }
    },
    event = 'BufReadPost',
    init = function()
      vim.o.foldenable = true
      vim.o.foldcolumn = '1'
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.fillchars = 'eob: ,fold: ,foldopen:,foldsep: ,foldclose:'
    end,
    opts = function()
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (' 󰁂 %d'):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
      end
      return {
        provider_selector = function()
          return { 'treesitter', 'indent' }
        end,
        fold_virt_text_handler = handler,
      }
    end,
    keys = {
      { "zR", mode = { "n" }, function() require('ufo').openAllFolds() end,  desc = "Open all folds" },
      { "zM", mode = { "n" }, function() require('ufo').closeAllFolds() end, desc = "Close all folds" },
      {
        "K",
        mode = { 'n' },
        function()
          local winid = require('ufo').peekFoldedLinesUnderCursor()
          if not winid then
            vim.lsp.buf.hover()
          end
        end,
        desc = "Hover"
      },
    },
  },

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
    opts = {
      ensure_installed = ensure_lsp,
    },
  },

  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = {
      'mason-org/mason-lspconfig.nvim',
    },
    opts = {
      ensure_installed = ensure_lsp,
    },
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
      -- Global mappings.
      local md = plugin_settings.nvim_lspconfig.mappings.diagnostic
      local mb = plugin_settings.nvim_lspconfig.mappings.buffer

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
        { md.open_float,          mode = { "n" },      vim.diagnostic.open_float,                           desc = "Open Diagnostic Message" },
        { md.goto_next,           mode = { "n" },      diagnostic_jump(true),                               desc = "Next Diagnostic" },
        { md.goto_prev,           mode = { "n" },      diagnostic_jump(false),                              desc = "Prev Diagnostic" },
        { md.goto_warn_next,      mode = { "n" },      diagnostic_jump(true, "WARN"),                       desc = "Next Warning" },
        { md.goto_warn_prev,      mode = { "n" },      diagnostic_jump(false, "WARN"),                      desc = "Prev Warning" },
        { md.goto_err_next,       mode = { "n" },      diagnostic_jump(true, "ERROR"),                      desc = "Next Error" },
        { md.goto_err_prev,       mode = { "n" },      diagnostic_jump(false, "ERROR"),                     desc = "Prev Error" },
        { md.open_list,           mode = { "n" },      vim.diagnostic.setloclist,                           desc = "Open Diagnostic List" },
        { mb.signature_help,      mode = { 'n', 'i' }, vim.lsp.buf.signature_help,                          desc = "Signature Help" },
        { mb.rename,              mode = { 'n' },      vim.lsp.buf.rename,                                  desc = "Rename" },
        { mb.code_action,         mode = { 'n', 'v' }, vim.lsp.buf.code_action,                             desc = "Code Action" },
        { mb.format,              mode = { 'n', 'v' }, function() vim.lsp.buf.format({ async = true }) end, desc = "Format" },
      }
    end,
    config = function()
      -- LSP log level
      -- vim.lsp.set_log_level("info")

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

      -- Extend LSP root_markers with a string or a table of strings
      ---@param lsp_name string
      ---@param root_markers string|string[]
      ---@return string|string[]
      local function extend_root_markers(lsp_name, root_markers)
        local defaults = vim.lsp.config[lsp_name].root_markers
        local result = {}

        if type(defaults) == "string" then
          result = { defaults }
        elseif type(defaults) == "table" then
          result = vim.list_extend({}, defaults) -- shallow copy
        end

        if type(root_markers) == "string" then
          table.insert(result, root_markers)
        elseif type(root_markers) == "table" then
          vim.list_extend(result, root_markers)
        end

        return result
      end

      -- Extend LSP filetypes with a string or a table of strings
      ---@param lsp_name string
      ---@param filetypes string|string[]
      ---@return string[]
      local function extend_filetypes(lsp_name, filetypes)
        local result = vim.lsp.config[lsp_name].filetypes or {}

        if type(filetypes) == "string" then
          table.insert(result, filetypes)
        elseif type(filetypes) == "table" then
          vim.list_extend(result, filetypes)
        end

        return result
      end

      --- lua_ls
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
      vim.lsp.enable("rust_analyzer")
      --- append lazy-lock.json for detecting neovim configuration
      vim.lsp.config("lua_ls", {
        root_markers = extend_root_markers("lua_ls", "lazy-lock.json")
      })
      --- svlangserver
      vim.lsp.config("svlangserver", {
        filetypes = extend_filetypes("svlangserver", "verilog_systemverilog"),
      })
      --- verible
      vim.lsp.config("verible", {
        cmd = {'verible-verilog-ls', '--rules_config_search'},
        root_markers = extend_root_markers("verible", 'verible.filelist'),
        filetypes = extend_filetypes("verible", "verilog_systemverilog"),
      })
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
        { path = "snacks.nvim",        words = { "Snacks"  } },
      },
    },
  },

  { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings

  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPost',
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        local m = plugin_settings.gitsigns.mappings
        -- Navigation
        map('n', m.next_hunk, function() gs.nav_hunk('next') end, { desc = "Next Hunk" })
        map('n', m.prev_hunk, function() gs.nav_hunk('prev') end, { desc = "Previous Hunk" })
        map("n", m.last_hunk, function() gs.nav_hunk("last") end, { desc = "Last Hunk" })
        map("n", m.first_hunk, function() gs.nav_hunk("first") end, { desc = "First Hunk" })

        -- Actions
        map('n', m.stage_hunk, gs.stage_hunk, { desc = "Stage Hunk" })
        map('n', m.reset_hunk, gs.reset_hunk, { desc = "Reset Hunk" })
        map('v', m.stage_hunk, function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = "Stage Hunk" })
        map('v', m.reset_hunk, function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = "Reset Hunk" })
        map('n', m.stage_buffer, gs.stage_buffer, { desc = "Stage Buffer" })
        map('n', m.reset_buffer, gs.reset_buffer, { desc = "Reset Buffer" })
        map('n', m.undo_stage_hunk, gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
        map('n', m.preview_hunk, gs.preview_hunk, { desc = "Preview Hunk" })
        map('n', m.blame_hunk, function() gs.blame_line { full = true } end, { desc = "Blame Hunk" })
        map('n', m.toggle_blame, gs.toggle_current_line_blame, { desc = "Toggle Blame" })
        map('n', m.diff_hunk, gs.diffthis, { desc = "Diff Hunk" })
        map('n', m.toggle_deleted, gs.toggle_deleted, { desc = "Toggle Deleted" })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = "Select Hunk" })
      end
    },
  },

  {
    'saghen/blink.cmp',
    dependencies = {
      'rafamadriz/friendly-snippets',
      {
        "mikavilpas/blink-ripgrep.nvim",
        version = "*",
      },
      "moyiz/blink-emoji.nvim",
      "folke/lazydev.nvim",
    },
    version = '*',
    event = 'InsertEnter',
    opts = {
      keymap = {
        preset = "default",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
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

  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "tinted-theming/tinted-nvim",
    },
    event = "VeryLazy",
    opts = function()
      local special_ft_display = {
        help = "Help",
        NvimTree = "NvimTree",
        lazy = "Lazy",
        TelescopePrompt = "Telescope",
        mason = "Mason",
        noice = "Noice",
        qf = "Quickfix",
        checkhealth = "Checkhealth",
        snacks_dashboard = "Dashboard",
        snacks_picker_input = "Picker Input",
        snacks_picker_list = "Picker List",
        snacks_layout_box = "",
        snacks_input = "Input",
        snacks_notif = "Notification",
        snacks_notif_history = "Notification History",
        snacks_terminal = "Terminal",
        trouble = "Trouble",
      }

      -- Helpers
      local function filename_or_filetype(str)
        local ft = vim.bo.filetype
        if special_ft_display[ft] then
          return special_ft_display[ft]
        end
        if vim.bo.buftype == 'terminal' then
          return str:gsub("term://", " "):gsub("/%d+:", " |  "):gsub("󰌾 ", "")
        end
        return str -- fallback to original filename
      end

      local function winbar_left()
        return ""
      end

      local function winbar_right()
        return ""
      end

      local theme = require('lualine.themes.tinted')
      local function winbar_sep_color(active)
        -- Terminal background
        local normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
        local term_bg = normal_hl.bg and string.format("#%06x", normal_hl.bg) or
            normal_hl.ctermbg and normal_hl.ctermbg or nil

        -- fg = theme bg, bg = terminal bg
        local theme_bg = active and theme.normal.b.bg or theme.inactive.b.bg

        return {
          fg = theme_bg,
          bg = term_bg,
        }
      end

      local function load_winbar()
        return vim.bo.buftype ~= 'terminal' and not special_ft_display[vim.bo.filetype]
      end

      local function load_statusline()
        return vim.bo.buftype ~= 'terminal'
      end

      local function make_winbar(active)
        return {
          lualine_a = {},
          lualine_b = {
            {
              winbar_left,
              separator = "",
              padding = 0,
              color = function() return winbar_sep_color(active) end,
              cond = load_winbar,
            },
            {
              'filetype',
              icon_only = true,
              separator = "",
              padding = 0,
              cond = load_winbar,
            },
            {
              'filename',
              symbols = {
                modified = ' ',
                readonly = '󰌾 ',
              },
              fmt = filename_or_filetype,
              separator = "",
              padding = 0,
              cond = load_winbar,
            },
            {
              winbar_right,
              separator = "",
              padding = 0,
              color = function() return winbar_sep_color(active) end,
              cond = load_winbar,
            },
          },
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {}
        }
      end

      local function location()
        local line = vim.fn.line('.')
        local col = vim.fn.charcol('.')
        return string.format('%-4d%-3d', line, col)
      end

      local function progress_render(str)
        return ' ' .. str
      end

      -- main configs
      local opts = {
        options = {
          theme = 'tinted',
          globalstatus = true,
          disabled_filetypes = {
            winbar = { 'NvimTree' },
          },
          events = {
            'WinEnter',
            'BufEnter',
            'BufWritePost',
            'SessionLoadPost',
            'FileChangedShellPost',
            'VimResized',
            'Filetype',
            'CursorMoved',
            'CursorMovedI',
            'ModeChanged',
            'TintedColorsPost',
          },
        },
        sections = {
          lualine_a = { { 'mode' } },
          lualine_b = {
            { 'branch', icon = '', separator = '', cond = load_statusline, },
            {
              'diff',
              symbols = { added = ' ', modified = ' ', removed = ' ' },
              source = function()
                local git_status = vim.b.gitsigns_status_dict
                if git_status then
                  return {
                    added = git_status.added,
                    modified = git_status.changed,
                    removed = git_status.removed
                  }
                end
                return nil
              end,
            },
          },
          lualine_c = {
            {
              'filename',
              path = 1,
              symbols = {
                modified = ' ',
                readonly = '󰌾 ',
              },
              fmt = filename_or_filetype,
            },
          },
          lualine_x = {
            'encoding', { 'fileformat', cond = load_statusline, }, 'filetype'
          },
          lualine_y = {
            {
              'diagnostics',
              sources = { 'nvim_diagnostic' },
            },
          },
          lualine_z = {
            {
              location,
              separator = "",
              padding = 0,
              cond = load_statusline,
            },
            {
              "progress",
              fmt = progress_render,
              cond = load_statusline,
            },
          },
        },
        winbar = make_winbar(true),
        inactive_winbar = make_winbar(false),
      }

      -- trouble.nvim
      local trouble = require("trouble")
      local symbols = trouble.statusline({
        mode = "lsp_document_symbols",
        groups = {},
        title = false,
        filter = { range = true },
        format = "{kind_icon}{symbol.name:Normal}",
        -- The following line is needed to fix the background color
        hl_group = "lualine_c_normal",
      })
      vim.api.nvim_set_hl(0, "StatusLine", { link = "lualine_c_normal" })
      table.insert(opts.sections.lualine_c, {
        symbols.get,
        cond = symbols.has,
      })

      return opts
    end
  },

  {
    "henry-hsieh/snacks.nvim",
    branch = 'feat-git-submodule-detect',
    priority = 1000,
    lazy = false,
    opts = function()
      Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>tw")
      Snacks.toggle.option("relativenumber", { name = "Relative Line Number" }):map("<leader>tr")
      Snacks.toggle.line_number():map("<leader>tl")
      Snacks.toggle.diagnostics():map("<leader>tD")
      Snacks.toggle.indent():map("<leader>tg")
      Snacks.toggle.inlay_hints():map("<leader>th")
      Snacks.toggle.new({
        id = "tabstop_4",
        name = "Tabstop 4",
        get = function()
          return vim.bo.tabstop == 4
        end,
        set = function(state)
          if state then
            vim.bo.tabstop = 4
            vim.bo.softtabstop = 4
            vim.bo.shiftwidth = 4
          else
            vim.bo.tabstop = 2
            vim.bo.softtabstop = 2
            vim.bo.shiftwidth = 2
          end
        end,
      }):map("<leader>t<Tab>")
      ---@type snacks.Config
      return {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        bigfile = { enabled = true },
        dashboard = {
          enabled = true,
        },
        explorer = {
          enabled = true,
          replace_netrw = false,
        },
        indent = { priority = 1, enabled = true },
        input = { enabled = true },
        picker = {
          enabled = true,
          hidden = true,
          matcher = {
            frecency = true,
          },
          sources = {
            files = {
              hidden = true,
            },
            explorer = {
              win = {
                list = {
                  keys = {
                    ["<CR>"] = { {"pick_win_file", "confirm"}, mode = { "n", "i" } },
                    ["<S-CR>"] = { "confirm", mode = { "n", "i" } },
                  },
                },
              },
            },
          },
          win = {
            input = {
              keys = {
                ["<CR>"] = { { "pick_win_file", "confirm" }, mode = { "n", "i" } },
                ["<S-CR>"] = { "confirm", mode = { "n", "i" } },
              },
            },
          },
          actions = {
            pick_win_file = function(picker, item)
              if item.dir then
                picker:action('confirm')
              else
                picker:action('pick_win')
              end
            end,
          },
        },
        notifier = { enabled = true },
        quickfile = { enabled = true },
        scope = { enabled = true },
        toggle = { enabled = true, },
        scroll = { enabled = true },
        words = { enabled = true },
        zen = { enabled = true, toggles = { diagnostics = false }, },
        styles = { zen = { backdrop = { transparent = false }}},
      }
    end,
    keys = {
      -- Top Pickers & Explorer
      { "<leader><space>", function() Snacks.picker.smart() end,                                   desc = "Smart Find Files" },
      { "<leader>,",       function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
      { "<leader>/",       function() Snacks.picker.grep() end,                                    desc = "Grep" },
      { "<leader>:",       function() Snacks.picker.command_history() end,                         desc = "Command History" },
      { "<leader>n",       function() Snacks.picker.notifications() end,                           desc = "Notification History" },
      {
        "<space>e",
        function()
          local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":p")
          local abs = vim.fn.fnamemodify(vim.fn.expand("%"), ":p:h")
          if abs:sub(1, #cwd) ~= cwd then
            cwd = abs
          end
          Snacks.explorer({ cwd = cwd })
        end,
        desc = "File Explorer"
      },
      -- find
      { "<leader>fb",      function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
      { "<leader>fc",      function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      { "<leader>ff",      function() Snacks.picker.files() end,                                   desc = "Find Files" },
      { "<leader>fg",      function() Snacks.picker.git_files() end,                               desc = "Find Git Files" },
      { "<leader>fp",      function() Snacks.picker.projects() end,                                desc = "Projects" },
      { "<leader>fr",      function() Snacks.picker.recent() end,                                  desc = "Recent" },
      -- git
      { "<leader>gb",      function() Snacks.picker.git_branches() end,                            desc = "Git Branches" },
      { "<leader>gl",      function() Snacks.picker.git_log() end,                                 desc = "Git Log" },
      { "<leader>gL",      function() Snacks.picker.git_log_line() end,                            desc = "Git Log Line" },
      { "<leader>gs",      function() Snacks.picker.git_status() end,                              desc = "Git Status" },
      { "<leader>gS",      function() Snacks.picker.git_stash() end,                               desc = "Git Stash" },
      { "<leader>gd",      function() Snacks.picker.git_diff() end,                                desc = "Git Diff (Hunks)" },
      { "<leader>gf",      function() Snacks.picker.git_log_file() end,                            desc = "Git Log File" },
      -- Grep
      { "<leader>sb",      function() Snacks.picker.lines() end,                                   desc = "Buffer Lines" },
      { "<leader>sB",      function() Snacks.picker.grep_buffers() end,                            desc = "Grep Open Buffers" },
      { "<leader>sg",      function() Snacks.picker.grep() end,                                    desc = "Grep" },
      { "<leader>sw",      function() Snacks.picker.grep_word() end,                               desc = "Visual selection or word", mode = { "n", "x" } },
      -- search
      { '<leader>s/',      function() Snacks.picker.search_history() end,                          desc = "Search History" },
      { "<leader>sc",      function() Snacks.picker.command_history() end,                         desc = "Command History" },
      { "<leader>sC",      function() Snacks.picker.commands() end,                                desc = "Commands" },
      { "<leader>sd",      function() Snacks.picker.diagnostics() end,                             desc = "Diagnostics" },
      { "<leader>sD",      function() Snacks.picker.diagnostics_buffer() end,                      desc = "Buffer Diagnostics" },
      { "<leader>sh",      function() Snacks.picker.help() end,                                    desc = "Help Pages" },
      { "<leader>sH",      function() Snacks.picker.highlights() end,                              desc = "Highlights" },
      { "<leader>si",      function() Snacks.picker.icons() end,                                   desc = "Icons" },
      { "<leader>sj",      function() Snacks.picker.jumps() end,                                   desc = "Jumps" },
      { "<leader>sk",      function() Snacks.picker.keymaps() end,                                 desc = "Keymaps" },
      { "<leader>sl",      function() Snacks.picker.loclist() end,                                 desc = "Location List" },
      { "<leader>sm",      function() Snacks.picker.marks() end,                                   desc = "Marks" },
      { "<leader>sM",      function() Snacks.picker.man() end,                                     desc = "Man Pages" },
      { "<leader>sp",      function() Snacks.picker.lazy() end,                                    desc = "Search for Plugin Spec" },
      { "<leader>sq",      function() Snacks.picker.qflist() end,                                  desc = "Quickfix List" },
      { "<leader>sR",      function() Snacks.picker.resume() end,                                  desc = "Resume" },
      { "<leader>su",      function() Snacks.picker.undo() end,                                    desc = "Undo History" },
      { "<leader>uC",      function() Snacks.picker.colorschemes() end,                            desc = "Colorschemes" },
      -- LSP
      { "gd",              function() Snacks.picker.lsp_definitions() end,                         desc = "Goto Definition" },
      { "gD",              function() Snacks.picker.lsp_declarations() end,                        desc = "Goto Declaration" },
      { "gr",              function() Snacks.picker.lsp_references() end,                          nowait = true,                     desc = "References" },
      { "gI",              function() Snacks.picker.lsp_implementations() end,                     desc = "Goto Implementation" },
      { "gy",              function() Snacks.picker.lsp_type_definitions() end,                    desc = "Goto T[y]pe Definition" },
      { "<leader>ss",      function() Snacks.picker.lsp_symbols() end,                             desc = "LSP Symbols" },
      { "<leader>sS",      function() Snacks.picker.lsp_workspace_symbols() end,                   desc = "LSP Workspace Symbols" },
      -- Lazygit
      { "<space>g",        function() Snacks.lazygit.open({cwd = Snacks.git.get_root()})   end,    desc = "Lazygit" },
      -- Git browse
      { "gB",              function() Snacks.gitbrowse() end,                                      desc = "Open in Git Browser" },
      -- Scratch Buffer
      { "<leader>.",       function() Snacks.scratch() end,                                        desc = "Toggle Scratch Buffer" },
      { "<leader>S",       function() Snacks.scratch.select() end,                                 desc = "Select Scratch Buffer" },
      -- Terminal
      { "<space>t",        function() Snacks.terminal() end,                                       desc = "Terminal" },
      -- Words
      { "gw",              function() Snacks.words.jump(1, true) end,                              desc = "Next Reference" },
      -- Zoom
      { "<C-w>z",          function() Snacks.zen.zoom() end,                                       desc = "Zoom" },
      { "<C-w>f",          function() Snacks.zen.zen() end,                                        desc = "Zen" },
      -- Bufdelete
      { "<space>bd",       function() Snacks.bufdelete() end,                                      desc = "Delete Buffer" },
      { "<space>bo",       function() Snacks.bufdelete.other() end,                                desc = "Delete Other Buffers" },
    },
  },

  {
    "henry-hsieh/riscv-asm-vim",
    ft = "riscv_asm",
    config = function()
      local s = plugin_settings.riscv_asm_vim.settings
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
      local s = plugin_settings.verilog_systemverilog.settings
      vim.g.verilog_disable_indent_lst = s.disable_indent
    end,
  },

  {
    'numToStr/Comment.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    opts = function()
      local ft = require('Comment.ft')
      local m = plugin_settings.comment.mappings

      ft({'verilog', 'verilog_systemverilog'}, ft.get('c'))

      return {
        ---LHS of toggle mappings in NORMAL mode
        toggler = {
          ---Line-comment toggle keymap
          line = m.toggle_line,
          ---Block-comment toggle keymap
          block = m.toggle_block,
        },
        ---LHS of operator-pending mappings in NORMAL and VISUAL mode
        opleader = {
          ---Line-comment keymap
          line = m.opleader_line,
          ---Block-comment keymap
          block = m.opleader_block,
        },
        ---LHS of extra mappings
        extra = {
          ---Add comment on the line above
          above = m.add_above,
          ---Add comment on the line below
          below = m.add_below,
          ---Add comment at the end of line
          eol = m.add_eol,
        },
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      }

    end,
    keys = function()
      local m = plugin_settings.comment.mappings
      local keys = {}
      for _, key in pairs(plugin_settings.comment.mappings) do
        table.insert(keys, key)
      end

      return keys
    end,
  },

    {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>h"   , group = "Hunk"},
        { "<leader>t"   , group = "Toggle"},
        { "<space>w"    , group = "Workspace"},
        { "<space><Tab>", group = "Tab"},
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },

  {
    'nanozuki/tabby.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    event = 'TabEnter',
    opts = function()
      local theme = {
        fill = 'TabLineFill',
        head = 'TabLine',
        current_tab = 'TabLineSel',
        tab = 'TabLine',
        win = 'TabLine',
        tail = 'TabLine',
      }
      return {
        line = function(line)
          return {
            {
              { ' 󰓩 ', hl = theme.head },
              line.sep('', theme.head, theme.fill),
            },
            line.tabs().foreach(function(tab)
              local hl = tab.is_current() and theme.current_tab or theme.tab
              return {
                line.sep('', hl, theme.fill),
                tab.is_current() and '' or '󰆣',
                tab.number(),
                tab.name(),
                tab.close_btn(''),
                line.sep('', hl, theme.fill),
                hl = hl,
                margin = ' ',
              }
            end),
            hl = theme.fill,
          }
        end,
      }
    end,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "henry-hsieh/snacks.nvim",
      "stevearc/dressing.nvim",
    },
    config = function()
      require("noice").setup({
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = false,
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = true, -- add a border to hover docs and signature help
        },
      })
      Snacks.input.enable()
      vim.ui.select = Snacks.picker.select
    end,
  },

  {
    "henry-hsieh/flash.nvim",
    dependencies = {
      {
        "henry-hsieh/snacks.nvim",
        opts = {
          picker = {
            win = {
              input = {
                keys = {
                  ["<a-s>"] = { "flash", mode = { "n", "i" } },
                  ["s"] = { "flash" },
                },
              },
            },
            actions = {
              flash = function(picker)
                require("flash").jump({
                  pattern = "^",
                  label = { after = { 0, 0 } },
                  search = {
                    mode = "search",
                    exclude = {
                      function(win)
                        return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
                      end,
                    },
                  },
                  action = function(match)
                    local idx = picker.list:row2idx(match.pos[1])
                    picker.list:_move(idx, true, true)
                  end,
                })
              end,
            },
          },
        },
      },
    },
    branch = 'feat-unique-label-win',
    ---@type Flash.Config
    opts = {
      labels = "asdfghjklqwertyuiopzxcvbnm",
      search = {
        exclude = {
          "notify",
          "cmp_menu",
          "noice",
          "flash_prompt",
          function(win)
            -- exclude non-focusable windows
            return not vim.api.nvim_win_get_config(win).focusable
          end,
        },
      },
      label = {
        uppercase = false,
      },
    },
    -- stylua: ignore
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
      {
        "<leader>w",
        mode = { "n", "x", "o" },
        function()
          require("flash-settings").jump_regex([[\<]])
        end,
        desc = "Jump to word start"
      },
      {
        "<leader>W",
        mode = { "n", "x", "o" },
        function()
          require("flash-settings").jump_regex([[\(^\|\s\+\)\zs\S\ze\S*]])
        end,
        desc = "Jump to WORD start"
      },
      {
        "<leader>e",
        mode = { "n", "x", "o" },
        function()
          require("flash-settings").jump_regex([[\w\>]])
        end,
        desc = "Jump to word end"
      },
      {
        "<leader>E",
        mode = { "n", "x", "o" },
        function()
          require("flash-settings").jump_regex([[\(^\|\s\+\)\S*\zs\S\ze]])
        end,
        desc = "Jump to WORD end"
      },
      {
        "<leader>l",
        mode = { "n", "x", "o" },
        function()
          require("flash-settings").jump_regex([[^\s*\zs\(\S\|$\)\ze]])
        end,
        desc = "Jump to line start"
      },
      {
        "<leader>L",
        mode = { "n", "x", "o" },
        function()
          require("flash-settings").jump_regex([[.\=$]])
        end,
        desc = "Jump to line end"
      },
    },
  },

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
          end
        end,
      })
      vim.cmd.doautocmd("User TintedColorsPost")
    end,
  },

  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },

  {
    "mikavilpas/yazi.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      {
        "<leader>yf",
        mode = { "n", "v" },
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        "<leader>yw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open yazi in current working directory",
      },
      {
        "<leader>yt",
        "<cmd>Yazi toggle<cr>",
        desc = "Toggle yazi session",
      },
    },
    ---@type YaziConfig | {}
    opts = {
      open_for_directories = true,
      keymaps = {
        show_help = "?",
        open_file_in_vertical_split = "<c-v>",
        open_file_in_horizontal_split = "<c-s>",
        open_file_in_tab = "<c-t>",
        grep_in_directory = "<c-g>",
        replace_in_directory = "<c-r>",
        cycle_open_buffers = "<tab>",
        copy_relative_path_to_selected_files = "<c-y>",
        send_to_quickfix_list = "<c-q>",
        change_working_directory = "<c-\\>",
        open_and_pick_window = "<c-o>",
      },
    },
    init = function()
      vim.g.loaded_netrwPlugin = 1
    end,
  }
},
{
  defaults = {
    lazy = true,
  },
})
