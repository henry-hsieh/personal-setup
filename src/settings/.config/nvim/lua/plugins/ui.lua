return {
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
        sidekick_terminal = "Terminal",
        trouble = "Trouble",
        ["codediff-explorer"] = "CodeDiff Explorer",
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
            winbar = { "blink-cmp-menu", "blink-cmp-signature", "blink-cmp-documentation" },
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

      return opts
    end
  },

  {
    "folke/snacks.nvim",
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
                    ["<C-O>"] = { { "pick_win", "jump" }, mode = { "n", "i" } },
                  },
                },
              },
            },
          },
          win = {
            input = {
              keys = {
                ["<C-O>"] = { { "pick_win", "jump" }, mode = { "n", "i" } },
              },
            },
          },
        },
        notifier = { enabled = true },
        quickfile = { enabled = true },
        scope = { enabled = true },
        toggle = { enabled = true, },
        scroll = { enabled = true },
        terminal = { win = { wo = { winbar = "" } } },
        words = { enabled = true },
        zen = { enabled = true, toggles = { diagnostics = false }, },
        styles = { zen = { backdrop = { transparent = false } } },
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
      -- GitHub CLI
      { "<leader>gi",      function() Snacks.picker.gh_issue() end,                                desc = "GitHub Issues (open)" },
      { "<leader>gI",      function() Snacks.picker.gh_issue({ state = "all" }) end,               desc = "GitHub Issues (all)" },
      { "<leader>gp",      function() Snacks.picker.gh_pr() end,                                   desc = "GitHub Pull Requests (open)" },
      { "<leader>gP",      function() Snacks.picker.gh_pr({ state = "all" }) end,                  desc = "GitHub Pull Requests (all)" },
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
      { "<space>g",        function() Snacks.lazygit.open({ cwd = Snacks.git.get_root() }) end,    desc = "Lazygit" },
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
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>h",    group = "Hunk" },
        { "<leader>t",    group = "Toggle" },
        { "<leader>c",    group = "Location", icon = { icon = "", color = "cyan" } },
        { "<leader>a",    group = "AI", icon = "🤖" },
        { "<leader>f",    group = "Find" },
        { "<leader>g",    group = "Git" },
        { "<leader>s",    group = "Search" },
        { "<leader>u",    group = "UI" },
        { "<leader>x",    group = "Trouble", icon = "🚦" },
        { "<leader>y",    group = "Yazi", icon = { icon = "󰇥", color = "yellow" } },
        { "<space>b",     group = "Buffer" },
        { "<space><Tab>", group = "Tab" },
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
      "folke/snacks.nvim",
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
}
