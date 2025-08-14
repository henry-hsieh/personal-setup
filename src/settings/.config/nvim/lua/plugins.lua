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
  "ltex",
  "bashls",
  "ts_ls",
  "jsonls",
}

local plugin_settings = require("plugin-settings")

require("lazy").setup({
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
    },
    config = function()
      local m = plugin_settings.telescope.mappings
      require('telescope').setup{
        defaults = {
          mappings = {
            i = {
              [m.close           ] = false,
              [m.horizontal_split] = require('telescope.actions').select_horizontal,
              [m.vertical_split  ] = require('telescope.actions').select_vertical,

              [m.scroll_up       ] = require('telescope.actions').results_scrolling_up,
              [m.scroll_down     ] = require('telescope.actions').results_scrolling_down,

              [m.move_up         ] = require('telescope.actions').move_selection_previous,
              [m.move_down       ] = require('telescope.actions').move_selection_next,

              [m.preview_up      ] = require('telescope.actions').preview_scrolling_up,
              [m.preview_down    ] = require('telescope.actions').preview_scrolling_down,
            },

            n = {
              [m.close           ] = false,
              [m.horizontal_split] = require('telescope.actions').select_horizontal,
              [m.vertical_split  ] = require('telescope.actions').select_vertical,

              [m.scroll_up       ] = require('telescope.actions').results_scrolling_up,
              [m.scroll_down     ] = require('telescope.actions').results_scrolling_down,

              [m.move_up         ] = require('telescope.actions').move_selection_previous,
              [m.move_down       ] = require('telescope.actions').move_selection_next,

              [m.preview_up      ] = require('telescope.actions').preview_scrolling_up,
              [m.preview_down    ] = require('telescope.actions').preview_scrolling_down,
            },
          },
          pickers = {
            find_files = {
              find_command = { "fd", "--type", "f", "--strip-cwd-prefix" }
            },
          },
        }
      }

      -- Load fzf extension
      require('telescope').load_extension('fzf')
    end
  },

  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = function(plugin)
      if vim.env.CC == 'musl-gcc' then
        require('utils').exec_shell_cmd('CFLAGS=-static make -C ' .. plugin.dir)
      else
        require('utils').exec_shell_cmd('make -C ' .. plugin.dir)
      end
    end,
  },

  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    dependencies = {
      'nvim-tree/nvim-web-devicons', -- optional, for file icon
    },
    config = function()
      local m = plugin_settings.nvim_tree.mappings
      local function my_on_attach(bufnr)
        local api = require "nvim-tree.api"

        local function opts(desc)
          return { desc = "Explorer " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- custom mappings
        vim.keymap.set('n', m.horizontal_split, api.node.open.horizontal,        opts('Open: Horizontal Split'))
        vim.keymap.set('n', m.vertical_split, api.node.open.vertical,        opts('Open: Vertical Split'))
        vim.keymap.set('n', '?',     api.tree.toggle_help,            opts('Help'))
      end

      local function git_disable_for_dirs(path)
        for _, p in ipairs(plugin_settings.nvim_tree.git_disable_dirs) do
          if path:find(p, 1, true) == 1 then
            return true
          end
        end
        return false
      end

      require'nvim-tree'.setup {
        on_attach = my_on_attach,
        git = {
          timeout = 800,
          show_on_open_dirs = false,
          disable_for_dirs = git_disable_for_dirs,
        },
        filesystem_watchers = {
          ignore_dirs = plugin_settings.nvim_tree.fs_watcher_ignore_dirs,
        },
      }

      -- map F9 to toogle NvimTree and focus on current file
      vim.api.nvim_set_keymap('n', m.toggle, '<cmd>NvimTreeFindFileToggle!<CR>', { desc = "Toggle Explorer", noremap = true, silent = true })
    end
  },

  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local opts = require("config.treesitter")
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
              if opts[lang].indent then
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
              end
            end
          end
        end,
      })
    end
  },

  {
    'henry-hsieh/mason.nvim',
    branch = 'feat-linker-exec-relative',
    config = function()
      require'mason'.setup{
        -- log_level = vim.log.levels.DEBUG,
      }
    end
  },

  {
    'mason-org/mason-lspconfig.nvim',
    event = 'VeryLazy',
    dependencies = {
      'folke/neoconf.nvim',
      {'henry-hsieh/mason.nvim', opts = {}},
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
    config = function()
      require('mason-tool-installer').setup {
        ensure_installed = ensure_lsp,
        -- Auto update is OFF by default
        -- Run :MasonToolsUpdate to install missing LSPs and update all LSPs
        --auto_update = true,
      }
    end
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'folke/neoconf.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    event = 'VeryLazy',
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
        { mb.goto_definition,     mode = { 'n' },      vim.lsp.buf.definition,                              desc = "Goto Definition" },
        { mb.hover,               mode = { 'n' },      vim.lsp.buf.hover,                                   desc = "Hover" },
        { mb.goto_implementation, mode = { 'n' },      vim.lsp.buf.implementation,                          desc = "Goto Implementation" },
        { mb.signature_help,      mode = { 'n', 'i' }, vim.lsp.buf.signature_help,                          desc = "Signature Help" },
        { mb.type_definition,     mode = { 'n' },      vim.lsp.buf.type_definition,                         desc = "Type Definition" },
        { mb.rename,              mode = { 'n' },      vim.lsp.buf.rename,                                  desc = "Rename" },
        { mb.code_action,         mode = { 'n', 'v' }, vim.lsp.buf.code_action,                             desc = "Code Action" },
        { mb.goto_reference,      mode = { 'n' },      vim.lsp.buf.references,                              desc = "Goto Reference" },
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

      --- global settings
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      vim.lsp.config('*', {
        capabilities = capabilities,
      })
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
      },
    },
  },

  { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings

  {
    'folke/neoconf.nvim',
    config = function()
      require("neoconf").setup({
      })
    end
  },

  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup{
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          local m = plugin_settings.gitsigns.mappings
          -- Navigation
          map('n', m.next_hunk, function() gs.nav_hunk('next') end, {desc = "Next Hunk"})
          map('n', m.prev_hunk, function() gs.nav_hunk('prev') end, {desc = "Previous Hunk"})
          map("n", m.last_hunk, function() gs.nav_hunk("last") end, {desc = "Last Hunk"})
          map("n", m.first_hunk, function() gs.nav_hunk("first") end, {desc = "First Hunk"})

          -- Actions
          map('n', m.stage_hunk, gs.stage_hunk, {desc = "Stage Hunk"})
          map('n', m.reset_hunk, gs.reset_hunk, {desc = "Reset Hunk"})
          map('v', m.stage_hunk, function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {desc = "Stage Hunk"})
          map('v', m.reset_hunk, function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {desc = "Reset Hunk"})
          map('n', m.stage_buffer, gs.stage_buffer, {desc = "Stage Buffer"})
          map('n', m.reset_buffer, gs.reset_buffer, {desc = "Reset Buffer"})
          map('n', m.undo_stage_hunk, gs.undo_stage_hunk, {desc = "Undo Stage Hunk"})
          map('n', m.preview_hunk, gs.preview_hunk, {desc = "Preview Hunk"})
          map('n', m.blame_hunk, function() gs.blame_line{full=true} end, {desc = "Blame Hunk"})
          map('n', m.toggle_blame, gs.toggle_current_line_blame, {desc = "Toggle Blame"})
          map('n', m.diff_hunk, gs.diffthis, {desc = "Diff Hunk"})
          map('n', m.toggle_deleted, gs.toggle_deleted, {desc = "Toggle Deleted"})

          -- Text object
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', {desc = "Select Hunk"})
        end
      }
    end,
  },

  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Completion and snippets
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      -- For vsnip users.
      -- 'hrsh7th/cmp-vsnip',
      -- 'hrsh7th/vim-vsnip',
      -- For luasnip users.
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      --
      -- For ultisnips users.
      -- 'SirVer/ultisnips',
      -- 'quangnguyen30192/cmp-nvim-ultisnips',
      --
      -- For snippy users.
      -- 'dcampos/nvim-snippy',
      -- 'dcampos/cmp-snippy',
    },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end,
    config = function()
      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
      end

      local kind_icons = {
        Text = "",
        Method = "󰆧",
        Function = "󰊕",
        Constructor = "",
        Field = "󰇽",
        Variable = "󰂡",
        Class = "󰠱",
        Interface = "",
        Module = "",
        Property = "󰜢",
        Unit = "",
        Value = "󰎠",
        Enum = "",
        Keyword = "󰌋",
        Snippet = "",
        Color = "󰏘",
        File = "󰈙",
        Reference = "",
        Folder = "󰉋",
        EnumMember = "",
        Constant = "󰏿",
        Struct = "",
        Event = "",
        Operator = "󰆕",
        TypeParameter = "󰅲",
      }

      local cmp = require "cmp"
      local luasnip = require "luasnip"
      local m = plugin_settings.nvim_cmp.mappings

      -- Map Shift-Tab to unindent a tab
      vim.api.nvim_set_keymap('i', '<S-Tab>', '<C-D>', { noremap = true, silent = true })

      cmp.setup{
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
          end,
        },
        window = {
          -- completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          [m.next_item] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),

          [m.prev_item] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          [m.scroll_up] = cmp.mapping.scroll_docs(-4),
          [m.scroll_down] = cmp.mapping.scroll_docs(4),
          [m.abort] = cmp.mapping.abort(),
          [m.confirm] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),

        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          -- { name = 'vsnip' }, -- For vsnip users.
          { name = 'luasnip' }, -- For luasnip users.
          -- { name = 'ultisnips' }, -- For ultisnips users.
          -- { name = 'snippy' }, -- For snippy users.
        }, {
          {
            name = 'buffer',
            option = {
              get_bufnrs = function()
                local bufs = {}
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  bufs[vim.api.nvim_win_get_buf(win)] = true
                end
                return vim.tbl_keys(bufs)
              end
            }
          }
        }),
        view = {
          entries = {
            name = "custom",
            selection_order = 'near_cursor'
          }
        },
        formatting = {
          format = function(entry, vim_item)
            -- Kind icons
            vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
            -- Source
            vim_item.menu = ({
              --buffer = "[Buffer]",
              --nvim_lsp = "[LSP]",
              --luasnip = "[LuaSnip]",
              --nvim_lua = "[Lua]",
              --latex_symbols = "[LaTeX]",
            })[entry.source.name]
            return vim_item
          end
        },
      }
      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })

      require("luasnip").config.setup({store_selection_keys="s"})
    end
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "tinted-theming/tinted-nvim",
    },
    event = "VeryLazy",
    opts = function()
      -- Helpers
      local function filename_or_filetype(str)
        local ft = vim.bo.filetype
        local special_ft_display = {
          help = "Help",
          NvimTree = "NvimTree",
          lazy = "Lazy",
          TelescopePrompt = "Telescope",
          mason = "Mason",
          noice = "Noice",
          qf = "Quickfix",
        }
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
        return vim.bo.buftype ~= 'terminal'
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
      return opts
    end
  },

  {
    "Pocco81/TrueZen.nvim",
    config = function()
      local true_zen = require("true-zen")

      true_zen.setup {
      }
      local m = plugin_settings.truezen.mappings
      -- map <C-w>a to toogle Ataraxis Mode
      vim.api.nvim_set_keymap('', m.ataraxis, '<cmd>TZAtaraxis<CR>', { desc = "Toggle Ataraxis Mode", noremap = true, silent = true })
      vim.api.nvim_set_keymap('i', m.ataraxis, '<cmd>TZAtaraxis<CR>', { desc = "Toggle Ataraxis Mode", noremap = true, silent = true })
      -- map <C-w>z to toogle Focus Mode
      vim.api.nvim_set_keymap('', m.focus, '<cmd>TZFocus<CR>', { desc = "Toggle Focus Mode", noremap = true, silent = true })
      vim.api.nvim_set_keymap('i', m.focus, '<cmd>TZFocus<CR>', { desc = "Toggle Focus Mode", noremap = true, silent = true })
      -- map <C-w>m to toogle Minimalist Mode
      vim.api.nvim_set_keymap('', m.minimalist, '<cmd>TZMinimalist<CR>', { desc = "Toggle Minimalist Mode", noremap = true, silent = true })
      vim.api.nvim_set_keymap('i', m.minimalist, '<cmd>TZMinimalist<CR>', { desc = "Toggle Minimalist Mode", noremap = true, silent = true })
    end,
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

  {"tpope/vim-fugitive"},

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
    lazy = false,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      local m = plugin_settings.comment.mappings
      require('Comment').setup {
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
      }

      local ft = require 'Comment.ft'
      ft({'verilog', 'systemverilog', 'verilog_systemverilog'}, ft.get('c'))
    end,
    init = function()
      -- nvim-ts-context-commentstring
      vim.g.skip_ts_context_commentstring_module = true
    end,
  },

  {
    "carbon-steel/detour.nvim",
    config = function ()
      require("detour").setup({
        title = "none",
      })
      vim.keymap.set('n', '<c-w><enter>', function()
        local popup_id = require("detour").Detour() -- Open a detour popup
        if not popup_id then
          return
        end
        vim.api.nvim_set_option_value("winbar", vim.api.nvim_get_option_value("winbar", {scope = "global"}), {scope = "local", win = popup_id})
      end, { desc = "Detour"})

      vim.keymap.set('n', '<c-w>.', function()
        local popup_id = require("detour").DetourCurrentWindow() -- Open a detour popup in current split
        if not popup_id then
          return
        end
        vim.api.nvim_set_option_value("winbar", vim.api.nvim_get_option_value("winbar", {scope = "global"}), {scope = "local", win = popup_id})
      end, { desc = "Detour Current Window"})

      vim.api.nvim_create_autocmd("BufWinEnter", {
        callback = function()
          local win = vim.api.nvim_get_current_win()
          if vim.tbl_contains(require('detour.internal').list_popups(), win) then
            vim.wo.winbar = vim.o.winbar
          end
        end,
      })

      vim.api.nvim_create_autocmd("BufWinEnter", {
        pattern = "*",
        callback = function(event)
          local filetype = vim.bo[event.buf].filetype
          local file_path = event.match

          if file_path:match "/doc/" ~= nil then
            -- Only run if the filetype is a help file
            if filetype == "help" or filetype == "markdown" then
              -- Get the newly opened help window
              -- and attempt to open a Detour() float
              local help_win = vim.api.nvim_get_current_win()
              local ok = require("detour").Detour()

              -- If we successfully create a float of the help file
              -- Close the split
              if ok then
                vim.api.nvim_win_close(help_win, false)
              end
            end
          end
        end,
      })
      -- Setup float for helps
      vim.api.nvim_create_autocmd("BufWinEnter", {
        pattern = "*",
        callback = function(event)
          local filetype = vim.bo[event.buf].filetype
          local file_path = event.match

          if file_path:match "/doc/" ~= nil then
            -- Only run if the filetype is a help file
            if filetype == "help" or filetype == "markdown" then
              -- Get the newly opened help window
              -- and attempt to open a Detour() float
              local help_win = vim.api.nvim_get_current_win()
              local ok = require("detour").Detour()

              -- If we successfully create a float of the help file
              -- Close the split
              if ok then
                vim.api.nvim_win_close(help_win, false)
              end
            end
          end
        end,
      })

      vim.api.nvim_set_keymap('', '<C-w>h', "<cmd>lua require('detour.movements').DetourWinCmdH()<CR>", { desc = "Goto Left Window", noremap = true, silent = true })
      vim.api.nvim_set_keymap('', '<C-w>l', "<cmd>lua require('detour.movements').DetourWinCmdL()<CR>", { desc = "Goto Right Window", noremap = true, silent = true })
      vim.api.nvim_set_keymap('', '<C-w>j', "<cmd>lua require('detour.movements').DetourWinCmdJ()<CR>", { desc = "Go Down Window", noremap = true, silent = true })
      vim.api.nvim_set_keymap('', '<C-w>k', "<cmd>lua require('detour.movements').DetourWinCmdK()<CR>", { desc = "Go Up Window", noremap = true, silent = true })

      vim.keymap.set('n', '<space>t', function()
        local terminal_buffer_found = false
        -- Check if we there are any existing terminal buffers.
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do -- iterate through all buffers
          if vim.api.nvim_buf_is_loaded(buf) then       -- only check loaded buffers
            if vim.api.nvim_get_option_value("buftype", { buf = buf }) == "terminal" then
              terminal_buffer_found = true
            end
          end
        end

        require('detour').Detour()                      -- Open a detour popup
        if terminal_buffer_found then
          require('telescope.builtin').buffers({})    -- Open telescope prompt
          vim.api.nvim_feedkeys("term://", "n", true) -- populate prompt with "term://"
        else
          vim.wo.signcolumn = "no"
          vim.cmd.lcd(vim.fn.expand("%:p:h"))
          vim.cmd.terminal()
          vim.cmd.startinsert()
        end

        vim.api.nvim_create_autocmd({"TermClose"}, {
          buffer = vim.api.nvim_get_current_buf(),
          callback = function ()
            -- This automated keypress skips for you the "[Process exited 0]" message
            -- that the embedded terminal shows.
            vim.api.nvim_feedkeys('i', 'n', false)
          end
        })
      end, { desc = "Open Terminal"})

      vim.keymap.set("n", '<space>p', function ()
        local ok = require('detour').Detour()  -- open a detour popup
        if not ok then
          return
        end

        vim.wo.signcolumn = "no"
        vim.cmd.terminal('htop')     -- open a terminal buffer
        vim.bo.bufhidden = 'delete' -- close the terminal when window closes

        vim.cmd.startinsert() -- go into insert mode

        vim.api.nvim_create_autocmd({"TermClose"}, {
          buffer = vim.api.nvim_get_current_buf(),
          callback = function ()
            -- This automated keypress skips for you the "[Process exited 0]" message
            -- that the embedded terminal shows.
            vim.api.nvim_feedkeys('i', 'n', false)
          end
        })
      end, { desc = "Open Htop"})

      vim.keymap.set("n", '<space>g', function ()
        local ok = require('detour').Detour()  -- open a detour popup
        if not ok then
          return
        end

        vim.wo.signcolumn = "no"
        vim.cmd.lcd(vim.fn.expand("%:p:h"))
        vim.cmd.terminal('lazygit')     -- open a terminal buffer
        vim.bo.bufhidden = 'delete' -- close the terminal when window closes

        vim.cmd.startinsert() -- go into insert mode

        vim.api.nvim_create_autocmd({"TermClose"}, {
          buffer = vim.api.nvim_get_current_buf(),
          callback = function ()
            -- This automated keypress skips for you the "[Process exited 0]" message
            -- that the embedded terminal shows.
            vim.api.nvim_feedkeys('i', 'n', false)
          end
        })
      end, { desc = "Open LazyGit"})
    end
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
    event = 'VeryLazy', -- if you want lazy load, see below
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      local theme = {
        fill = 'TabLineFill',
        head = 'TabLine',
        current_tab = 'TabLineSel',
        tab = 'TabLine',
        win = 'TabLine',
        tail = 'TabLine',
      }
      require('tabby').setup({
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
        -- option = {}, -- setup modules' option,
      })
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
      "rcarriga/nvim-notify",
      "stevearc/dressing.nvim",
    },
    config = function()
      require("noice").setup({
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
      })
    end,
  },
  {
    "henry-hsieh/flash.nvim",
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
          function(win)
            -- exclude covered detoured windows
            if require("lazy.core.config").plugins["detour.nvim"]._.loaded then
              return vim.tbl_contains(require('detour.internal').list_coverable_windows(), win)
            end
            return true
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
            vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = colors.base09, bg = nil,           bold = false, italic = false })
            vim.api.nvim_set_hl(0, "FlashLabel",     { fg = colors.base06, bg = colors.base08, bold = false, italic = false })
            vim.api.nvim_set_hl(0, "FlashMatch",     { fg = colors.base06, bg = colors.base0D, bold = false, italic = false })
          end
        end,
      })
      vim.cmd.doautocmd("User TintedColorsPost")
    end,
  },
})
