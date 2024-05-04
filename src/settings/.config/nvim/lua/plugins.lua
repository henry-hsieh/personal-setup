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
  "tsserver",
}

-- Tree-Sitter list
local ensure_ts = {
  "c",
  "cpp",
  "lua",
  "vim",
  "vimdoc",
  "query",
  "bash",
  "python",
  "javascript",
  "verilog",
  "gitcommit",
  "git_rebase",
  "make",
  "markdown",
  "latex",
  "rust",
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
    'kyazdani42/nvim-tree.lua',
    dependencies = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icon
    },
    config = function()
      local m = plugin_settings.nvim_tree.mappings
      local function my_on_attach(bufnr)
        local api = require "nvim-tree.api"

        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- custom mappings
        vim.keymap.set('n', m.horizontal_split, api.node.open.horizontal,        opts('Open: Horizontal Split'))
        vim.keymap.set('n', m.vertical_split, api.node.open.vertical,        opts('Open: Vertical Split'))
        vim.keymap.set('n', '?',     api.tree.toggle_help,            opts('Help'))
      end

      require'nvim-tree'.setup {
        on_attach = my_on_attach,
      }

      -- map F9 to toogle NvimTree and focus on current file
      vim.api.nvim_set_keymap('n', m.toggle, '<cmd>NvimTreeFindFileToggle!<CR>', { noremap = true, silent = true })
    end
  },

  {
    'smoka7/hop.nvim',
    dependencies = {
      "carbon-steel/detour.nvim",
    },
    config = function()
      require'hop'.setup {
        keys = 'asdfghjkl;qwertyuiopzxcvbnm',
        char2_fallback_key = '<Esc>',
        multi_windows = true,
        hl_mode = 'replace',
        windows_list = function ()
          return vim.tbl_filter(function(window)
            return not vim.tbl_contains(require('detour.internal').list_coverable_windows(), window)
          end, vim.api.nvim_tabpage_list_wins(0))
        end,
      }
    end
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require'nvim-treesitter.install'.command_extra_args = {["musl-gcc"] = {"-static"}}
      require'nvim-treesitter.configs'.setup {
        ensure_installed = ensure_ts,
        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = true,
        -- Automatically install missing parsers when entering buffer
        auto_install = false,

        highlight = {
          enable = true,

          -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
          -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
          -- the name of the parser)
          -- list of language that will be disabled
          -- disable = { "c", "rust" },
          -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
            if lang == 'verilog' then
              return true
            end
          end,

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      }
      vim.treesitter.language.register('verilog', 'verilog_systemverilog')
    end
  },

  {
    'nvim-treesitter/playground',
    config = function()
      require "nvim-treesitter.configs".setup {
        playground = {
          enable = true,
          disable = {},
          updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
          persist_queries = false, -- Whether the query persists across vim sessions
          keybindings = {
            toggle_query_editor = 'o',
            toggle_hl_groups = 'i',
            toggle_injected_languages = 't',
            toggle_anonymous_nodes = 'a',
            toggle_language_display = 'I',
            focus_language = 'f',
            unfocus_language = 'F',
            update = 'R',
            goto_node = '<cr>',
            show_help = '?',
          },
        }
      }
    end
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require'nvim-treesitter.configs'.setup {
        textobjects = {
          select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inter",
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["as"] = "@statement.outer",
              ["am"] = "@comment.inter",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["<leader>a"] = "@parameter.inner",
            },
            swap_previous = {
              ["<leader>A"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]b"] = "@block.outer",
              ["]f"] = "@function.outer",
              ["]]"] = "@class.outer",
              ["]s"] = "@statement.outer",
              ["]m"] = "@comment.outer",
            },
            goto_next_end = {
              ["]B"] = "@block.outer",
              ["]F"] = "@function.outer",
              ["]["] = "@class.outer",
              ["]S"] = "@statement.outer",
              ["]M"] = "@comment.outer",
            },
            goto_previous_start = {
              ["[b"] = "@block.outer",
              ["[f"] = "@function.outer",
              ["[["] = "@class.outer",
              ["[s"] = "@statement.outer",
              ["[m"] = "@comment.outer",
            },
            goto_previous_end = {
              ["[B"] = "@block.outer",
              ["[F"] = "@function.outer",
              ["[]"] = "@class.outer",
              ["[S"] = "@statement.outer",
              ["[M"] = "@comment.outer",
            },
          },
        },
      }
    end
  },

  {
    'henry-hsieh/mason.nvim',
    branch = 'v2.x',
    config = function()
      require'mason'.setup{
        -- log_level = vim.log.levels.DEBUG,
      }
    end
  },

  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'henry-hsieh/mason.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local handlers = {
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.
        function (server_name) -- default handler (optional)
          require("lspconfig")[server_name].setup {
            capabilities = capabilities,
          }
        end,
        -- Next, you can provide targeted overrides for specific servers.
        ["rust_analyzer"] = function ()
          require("rust-tools").setup {}
        end,
        ["lua_ls"] = function ()
          local lspconfig = require("lspconfig")
          lspconfig.lua_ls.setup {
            settings = {
              Lua = {
                runtime = {
                  version = "LuaJIT"
                },
                workspace = {
                  checkThirdParty = false,
                  library = {
                    vim.env.VIMRUNTIME
                  },
                },
              },
            },
            capabilities = capabilities,
          }
        end,
        ["svlangserver"] = function ()
          local on_attach = function(client, bufnr)
            require('nlspsettings').update_settings(client.name)
          end
          local lspconfig = require("lspconfig")
          lspconfig.svlangserver.setup {
            on_attach = on_attach,
            filetypes = {'verilog', 'systemverilog', 'verilog_systemverilog'},
            capabilities = capabilities,
          }
        end,
        ["verible"] = function ()
          local lspconfig = require("lspconfig")
          lspconfig.verible.setup {
            cmd = {'verible-verilog-ls', '--rules_config_search'},
            filetypes = {'verilog', 'systemverilog', 'verilog_systemverilog'},
            capabilities = capabilities,
          }
        end,
        ["bashls"] = function ()
          local lspconfig = require("lspconfig")
          lspconfig.bashls.setup {
            settings = {
              bashIde = {
                globPattern = "" -- Add for avoiding freeze
              }
            },
            capabilities = capabilities,
          }
        end,
      }
      require'mason-lspconfig'.setup{
        ensure_installed = ensure_lsp,
        handlers = handlers,
      }
    end
  },

  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    branch = 'mason_2.x_api',
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
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
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      -- Set LSP symbols
      local function lspSymbol(name, icon)
        vim.fn.sign_define(
          'DiagnosticSign' .. name,
          { text = icon, texthl = 'Diagnostic' .. name }
        )
      end
      lspSymbol('Error', '')
      lspSymbol('Hint', '')
      lspSymbol('Info', '')
      lspSymbol('Warn', '')
      -- LSP log level
      --vim.lsp.set_log_level("info")

      -- Global mappings.
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions
      local md = plugin_settings.nvim_lspconfig.mappings.diagnostic
      vim.keymap.set('n', md.open_float, vim.diagnostic.open_float)
      vim.keymap.set('n', md.goto_prev, vim.diagnostic.goto_prev)
      vim.keymap.set('n', md.goto_next, vim.diagnostic.goto_next)
      vim.keymap.set('n', md.open_list, vim.diagnostic.setloclist)

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          local mb = plugin_settings.nvim_lspconfig.mappings.buffer
          vim.keymap.set('n', mb.goto_declaration, vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', mb.goto_definition, vim.lsp.buf.definition, opts)
          vim.keymap.set('n', mb.hover, vim.lsp.buf.hover, opts)
          vim.keymap.set('n', mb.goto_implementation, vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', mb.signature_help, vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', mb.add_workspace_folder, vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set('n', mb.remove_workspace_folder, vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set('n', mb.list_workspace_folder, function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set('n', mb.type_definition, vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', mb.rename, vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, mb.code_action, vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', mb.goto_reference, vim.lsp.buf.references, opts)
          vim.keymap.set({ 'n', 'v' }, mb.format, function()
            vim.lsp.buf.format { async = true }
          end, opts)
        end,
      })
    end,
  },

  {
    'tamago324/nlsp-settings.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
    },
    config = function()
      require'nlspsettings'.setup{
        config_home = vim.fn.stdpath('config') .. '/nlsp-settings',
        local_settings_dir = ".nlsp-settings",
        local_settings_root_markers = { '.git' },
        append_default_schemas = false,
        loader = 'json'
      }
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
          map('n', m.next_hunk, function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          map('n', m.prev_hunk, function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          -- Actions
          map('n', m.stage_hunk, gs.stage_hunk)
          map('n', m.reset_hunk, gs.reset_hunk)
          map('v', m.stage_hunk, function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
          map('v', m.reset_hunk, function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
          map('n', m.stage_buffer, gs.stage_buffer)
          map('n', m.reset_buffer, gs.reset_buffer)
          map('n', m.undo_stage_hunk, gs.undo_stage_hunk)
          map('n', m.preview_hunk, gs.preview_hunk)
          map('n', m.blame_hunk, function() gs.blame_line{full=true} end)
          map('n', m.toggle_blame, gs.toggle_current_line_blame)
          map('n', m.diff_hunk, gs.diffthis)
          map('n', m.toggle_deleted, gs.toggle_deleted)

          -- Text object
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
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
    'RRethy/nvim-base16',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      local default_theme = "base16-default-dark"

      local function get_tinty_theme()
        local theme_name = vim.fn.system("tinty current &> /dev/null && tinty current")

        if vim.v.shell_error ~= 0 then
          return default_theme
        else
          return theme_name:gsub("\n", "")
        end
      end


      local function handle_focus_gained()
        local new_theme_name = get_tinty_theme()
        local current_theme_name = vim.g.colors_name

        if current_theme_name ~= new_theme_name then
          vim.cmd("colorscheme " .. new_theme_name)
        end
      end

      local current_theme_name = get_tinty_theme()
      vim.cmd("colorscheme " .. current_theme_name)

      vim.api.nvim_create_autocmd("FocusGained", {
        callback = handle_focus_gained,
        nested = true,
      })

      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        callback = function ()
          local base16 = require('base16-colorscheme')
          base16.highlight.DiagnosticWarn = { guifg = base16.colors.base09, guibg = nil, gui = 'none', guisp = nil, ctermfg = base16.colors.cterm0E, ctermbg = nil }
        end
      })
    end,
  },

  {
    'freddiehaddad/feline.nvim',
    version = '*',
    config = function()
      -- Feline statusline definition.
      --
      -- Note: This statusline does not define any colors. Instead the statusline is
      -- built on custom highlight groups that I define. The colors for these
      -- highlight groups are pulled from the current colorscheme applied. Check the
      -- file: `lua/eden/modules/ui/colors.lua` to see how they are defined.

      --local u = require("eden.modules.ui.feline.util")
      local fmt = string.format

      -- "┃", "█", "", "", "", "", "", "", "●"

      local function tbl_size(tbl)
        local size = 0
        for _ in pairs(tbl) do
          size = size + 1
        end
        return size
      end

      local get_diag = function(str)
        local count = tbl_size(vim.diagnostic.get(0, { severity = vim.diagnostic.severity[str] }))
        return (count > 0) and " " .. count .. " " or ""
      end

      local function base16_hl(fg, bg, style)
        local hl = {}
        if fg then
          hl.fg = vim.g['base16_gui' .. fmt("%02X", fg)] and vim.g['base16_gui' .. fmt("%02X", fg)] or vim.g.terminal_color_foreground
        end
        if bg then
          hl.bg = vim.g['base16_gui' .. fmt("%02X", bg)] and vim.g['base16_gui' .. fmt("%02X", bg)] or vim.g.terminal_color_background
        end
        if style then
          hl.style = style
        end
        return hl
      end

      local vi_mode_colors = {
        ['NORMAL']    = function() return base16_hl(0,11,'bold') end,
        ['OP']        = function() return base16_hl(0,11,'bold') end,
        ['INSERT']    = function() return base16_hl(1,13,'bold') end,
        ['VISUAL']    = function() return base16_hl(1,14,'bold') end,
        ['LINES']     = function() return base16_hl(1,14,'bold') end,
        ['BLOCK']     = function() return base16_hl(1,14,'bold') end,
        ['REPLACE']   = function() return base16_hl(1, 8,'bold') end,
        ['V-REPLACE'] = function() return base16_hl(1, 8,'bold') end,
        ['ENTER']     = function() return base16_hl(1,12,'bold') end,
        ['MORE']      = function() return base16_hl(1,12,'bold') end,
        ['SELECT']    = function() return base16_hl(1, 9,'bold') end,
        ['COMMAND']   = function() return base16_hl(0,11,'bold') end,
        ['SHELL']     = function() return base16_hl(0,11,'bold') end,
        ['TERM']      = function() return base16_hl(0,11,'bold') end,
        ['NONE']      = function() return base16_hl(1,10,'bold') end,
      }

      local vi_sep_colors = {
        ['NORMAL']    = function() return base16_hl(11,1,'bold') end,
        ['OP']        = function() return base16_hl(11,1,'bold') end,
        ['INSERT']    = function() return base16_hl(13,1,'bold') end,
        ['VISUAL']    = function() return base16_hl(14,1,'bold') end,
        ['LINES']     = function() return base16_hl(14,1,'bold') end,
        ['BLOCK']     = function() return base16_hl(14,1,'bold') end,
        ['REPLACE']   = function() return base16_hl( 8,1,'bold') end,
        ['V-REPLACE'] = function() return base16_hl( 8,1,'bold') end,
        ['ENTER']     = function() return base16_hl(12,1,'bold') end,
        ['MORE']      = function() return base16_hl(12,1,'bold') end,
        ['SELECT']    = function() return base16_hl( 9,1,'bold') end,
        ['COMMAND']   = function() return base16_hl(11,1,'bold') end,
        ['SHELL']     = function() return base16_hl(11,1,'bold') end,
        ['TERM']      = function() return base16_hl(11,1,'bold') end,
        ['NONE']      = function() return base16_hl(10,1,'bold') end,
      }

      local function vi_mode_hl()
        return vi_mode_colors[require("feline.providers.vi_mode").get_vim_mode()]() or vi_mode_colors['NONE']()
      end

      local function vi_sep_hl()
        return vi_sep_colors[require("feline.providers.vi_mode").get_vim_mode()]() or vi_sep_colors['NONE']()
      end

      local function index(tab, val)
        for idx, value in ipairs(tab) do
          if value == val then
            return idx
          end
        end
        return 0
      end

      local c = {
        vi_mode = {
          provider = function()
            return fmt(" %s ", require("feline.providers.vi_mode").get_vim_mode())
          end,
          hl = function()
            return vi_mode_hl()
          end,
          right_sep = {
            str = "",
            hl = function()
              return vi_sep_hl()
            end,
          },
        },
        git_branch = {
          provider = "git_branch",
          icon = "  ",
          hl = function()
            return base16_hl(4, 1,'None')
          end,
          right_sep = {
            str = " ",
            hl = function()
              return base16_hl(4, 1,'None')
            end,
          },
          enabled = function()
            return vim.b.gitsigns_status_dict ~= nil
          end,
        },
        git_diff_added = {
          provider = "git_diff_added",
          icon = " ",
          hl = function()
            local hl = base16_hl(1, 1,'None')
            hl.fg = string.format("#%06x", vim.api.nvim_get_hl(0, {name = 'GitSignsAdd', link = false}).fg)
            return hl
          end,
          right_sep = {
            str = " ",
            hl = function()
              return base16_hl(4, 1,'None')
            end,
          },
          enabled = function()
            return vim.b.gitsigns_status_dict ~= nil
          end,
        },
        git_diff_changed = {
          provider = "git_diff_changed",
          icon = " ",
          hl = function()
            local hl = base16_hl(1, 1,'None')
            hl.fg = string.format("#%06x", vim.api.nvim_get_hl(0, {name = 'GitSignsChange', link = false}).fg)
            return hl
          end,
          right_sep = {
            str = " ",
            hl = function()
              return base16_hl(4, 1,'None')
            end,
          },
          enabled = function()
            return vim.b.gitsigns_status_dict ~= nil
          end,
        },
        git_diff_removed = {
          provider = "git_diff_removed",
          icon = " ",
          hl = function()
            local hl = base16_hl(1, 1,'None')
            hl.fg = string.format("#%06x", vim.api.nvim_get_hl(0, {name = 'GitSignsDelete', link = false}).fg)
            return hl
          end,
          right_sep = {
            str = " ",
            hl = function()
              return base16_hl(4, 1,'None')
            end,
          },
          enabled = function()
            return vim.b.gitsigns_status_dict ~= nil
          end,
        },
        file_info = {
          provider = {
            name = "file_info",
            opts = {
              type = "relative",
              file_modified_icon = " ",
              file_readonly_icon = "󰌾 ",
            }
          },
          short_provider = {
            name = "file_info",
            opts = {
              type = "relative-short",
              file_modified_icon = " ",
              file_readonly_icon = "󰌾 ",
            }
          },
          hl = function()
            return base16_hl(6, 2,'None')
          end,
          left_sep = {
            str = " ",
            hl = function()
              return base16_hl(1, 2,'None')
            end,
          },
          right_sep = {
            str = function()
              if vim.bo.modified then
                return ""
              else
                return "█"
              end
            end,
            hl = function()
              return base16_hl(2, 1,'None')
            end,
          },
        },
        file_encoding = {
          provider = function()
            return require("feline.providers.file").file_encoding() .. " "
          end,
          icon = function()
            local os = vim.bo.fileformat:upper()
            local icon
            if os == 'UNIX' then
              icon = ' '
            elseif os == 'MAC' then
              icon = ' '
            else
              icon = ' '
            end
            return icon
          end,
          hl = function()
            return base16_hl(6, 2,'None')
          end,
          right_sep = {
            str = "",
            hl = function()
              return base16_hl(1, 2,'None')
            end,
          },
        },
        file_type = {
          provider = function()
            return fmt(" %s ", vim.bo.filetype)
          end,
          hl = function()
            return base16_hl(6, 2,'None')
          end,
          right_sep = {
            str = " ",
            hl = function()
              return base16_hl(6, 2,'None')
            end,
          },
          left_sep = {
            str = "",
            hl = function()
              return base16_hl(2, 10, "None")
            end,
          },
        },
        warning = {
          provider = function()
            local str = ''
            if vim.fn.getfsize(vim.fn.expand('%:p')) < 10485760 then -- 10MB
              -- Mixed indent
              local c_like_langs = {'arduino', 'c', 'cpp', 'cuda', 'go', 'javascript', 'ld', 'php' ,'verilog', 'systemverilog', 'verilog_systemverilog'}
              local head_space
              if index(c_like_langs, vim.o.ft) > 0 then
                head_space = '\\v(^ +\\*@!)'
              else
                head_space = '\\v(^ +)'
              end
              local indent_tabs = vim.fn.search('\\v(^\\t+)', 'nw', 0 ,150)
              local indent_spaces = vim.fn.search(head_space, 'nw', 0 ,150)
              if indent_tabs > 0 and indent_spaces > 0 then
                str = "  " .. fmt("%d:%d", indent_tabs, indent_spaces) .. str
              end

              -- Trailing spaces or tabs
              local trailing = vim.fn.search('\\s$', 'nw', 0 ,150)
              if trailing > 0 then
                str = " 󱁐 " .. fmt("%d", trailing) .. str
              end

              -- Git conflicts
              if vim.b.gitsigns_status_dict ~= nil then
                local annotation = '\\%([0-9A-Za-z_.:]\\+\\)\\?'
                local rst_like_langs = {'rst', 'markdown'}
                local pattern
                if index(rst_like_langs, vim.o.ft) > 0 then
                  pattern = '^\\%(\\%(<\\{7} ' .. annotation .. '\\)\\|\\%(>\\{7\\} ' .. annotation .. '\\)\\)$'
                else
                  pattern = '^\\%(\\%(<\\{7} ' .. annotation .. '\\)\\|\\%(=\\{7\\}\\)\\|\\%(>\\{7\\} ' .. annotation .. '\\)\\)$'
                end
                local conflicts = vim.fn.search(pattern, "nw", 0, 200)
                if conflicts > 0 then
                  str = "  " .. fmt("%d", conflicts) .. str
                end
              end
            end
            return str
          end,
          hl = function()
            return base16_hl(1, 10,'None')
          end,
          right_sep = {
            str = " ",
            hl = function()
              return base16_hl(1, 10,'None')
            end,
          },
          --updated = { 'BufWinEnter', 'ModeChanged' },
        },
        sep_warning = {
          left_sep = {
            str = "",
            hl = function()
              if require("feline.providers.lsp").is_lsp_attached() then
                return base16_hl(10, 12, "None")
              else
                return base16_hl(10, 1, "None")
              end
            end,
            always_visible = true
          },
        },
        position = {
          provider = {
            name = "position",
            opts = {
              format = "{line} {col} ",
            },
          },
          hl = function()
            return vi_mode_hl()
          end,
          left_sep = {
            str = "█",
            hl = function()
              return vi_sep_hl()
            end,
          },
        },
        line_percentage = {
          provider = function()
            return "%p%% "
          end,
          icon = " ",
          hl = function()
            return vi_mode_hl()
          end,
        },
        lsp_error = {
          provider = function()
            return get_diag("ERROR")
          end,
          hl = function()
            local hl = base16_hl(1, 1,'None')
            hl.bg = string.format("#%06x", vim.api.nvim_get_hl(0, {name = 'DiagnosticError', link = false}).fg)
            return hl
          end,
          left_sep = {
            str = "",
            hl = function()
              local hl = base16_hl(1, 1,'None')
              hl.fg = string.format("#%06x", vim.api.nvim_get_hl(0, {name = 'DiagnosticError', link = false}).fg)
              return hl
            end,
            always_visible = true
          },
          enabled = function()
            return require("feline.providers.lsp").is_lsp_attached()
          end,
        },
        lsp_warn = {
          provider = function()
            return get_diag("WARN")
          end,
          hl = function()
            local hl = base16_hl(1, 1,'None')
            hl.bg = string.format("#%06x", vim.api.nvim_get_hl(0, {name = 'DiagnosticWarn', link = false}).fg)
            return hl
          end,
          left_sep = {
            str = "",
            hl = function()
              local hl = {}
              hl.fg = string.format("#%06x", vim.api.nvim_get_hl(0, {name = 'DiagnosticWarn', link = false}).fg)
              hl.bg = string.format("#%06x", vim.api.nvim_get_hl(0, {name = 'DiagnosticError', link = false}).fg)
              return hl
            end,
            always_visible = true
          },
          enabled = function()
            return require("feline.providers.lsp").is_lsp_attached()
          end,
        },
        lsp_info = {
          provider = function()
            return get_diag("INFO")
          end,
          hl = function()
            local hl = base16_hl(1, 1,'None')
            hl.bg = string.format("#%06x", vim.api.nvim_get_hl(0, {name = 'DiagnosticInfo', link = false}).fg)
            return hl
          end,
          left_sep = {
            str = "",
            hl = function()
              local hl = {}
              hl.fg = string.format("#%06x", vim.api.nvim_get_hl(0, {name = 'DiagnosticInfo', link = false}).fg)
              hl.bg = string.format("#%06x", vim.api.nvim_get_hl(0, {name = 'DiagnosticWarn', link = false}).fg)
              return hl
            end,
            always_visible = true
          },
          enabled = function()
            return require("feline.providers.lsp").is_lsp_attached()
          end,
        },
        lsp_hint = {
          provider = function()
            return get_diag("HINT")
          end,
          hl = function()
            local hl = base16_hl(1, 1,'None')
            hl.bg = string.format("#%06x", vim.api.nvim_get_hl(0, {name = 'DiagnosticHint', link = false}).fg)
            return hl
          end,
          left_sep = {
            str = "",
            hl = function()
              local hl = {}
              hl.fg = string.format("#%06x", vim.api.nvim_get_hl(0, {name = 'DiagnosticHint', link = false}).fg)
              hl.bg = string.format("#%06x", vim.api.nvim_get_hl(0, {name = 'DiagnosticInfo', link = false}).fg)
              return hl
            end,
            always_visible = true
          },
          enabled = function()
            return require("feline.providers.lsp").is_lsp_attached()
          end,
        },
        inactive = {
          provider = function()
            return " INACTIVE"
          end,
          short_provider = function()
            return "  "
          end,
          hl = function()
            return base16_hl(4, 1, "None")
          end,
          right_sep = {
            str = " ",
            hl = function()
              return base16_hl(4, 1, "None")
            end,
          },
        },
        inactive_file_info = {
          provider = {
            name = "file_info",
            opts = {
              type = "relative",
              file_modified_icon = " ",
              file_readonly_icon = "󰌾 ",
            }
          },
          short_provider = {
            name = "file_info",
            opts = {
              type = "relative-short",
              file_modified_icon = " ",
              file_readonly_icon = "󰌾 ",
            }
          },
          hl = function()
            return base16_hl(4, 2,'None')
          end,
          left_sep = {
            str = " ",
            hl = function()
              return base16_hl(1, 2,'None')
            end,
          },
          right_sep = {
            str = function()
              if vim.bo.modified then
                return ""
              else
                return "█"
              end
            end,
            hl = function()
              return base16_hl(2, 1,'None')
            end,
          },
        },
        inactive_file_encoding = {
          provider = function()
            return require("feline.providers.file").file_encoding() .. " "
          end,
          icon = function()
            local os = vim.bo.fileformat:upper()
            local icon
            if os == 'UNIX' then
              icon = ' '
            elseif os == 'MAC' then
              icon = ' '
            else
              icon = ' '
            end
            return icon
          end,
          hl = function()
            return base16_hl(4, 2,'None')
          end,
          right_sep = {
            str = "",
            hl = function()
              return base16_hl(1, 2,'None')
            end,
          },
        },
        inactive_file_type = {
          provider = function()
            return fmt(" %s ", vim.bo.filetype)
          end,
          hl = function()
            return base16_hl(4, 2,'None')
          end,
          right_sep = {
            str = " ",
            hl = function()
              return base16_hl(4, 2,'None')
            end,
          },
          left_sep = {
            str = "",
            hl = function()
              return base16_hl(2, 1, "None")
            end,
          },
        },
        inactive_position = {
          provider = {
            name = "position",
            opts = {
              format = "{line} {col} ",
            },
          },
          hl = function()
            return base16_hl(4, 1, "None")
          end,
          left_sep = {
            str = "  ",
            hl = function()
              return base16_hl(4, 1, "None")
            end,
          },
        },
        inactive_line_percentage = {
          provider = function()
            return "%p%% "
          end,
          icon = " ",
          hl = function()
            return base16_hl(4, 1, "None")
          end,
        },
      }

      local active = {
        { -- left
          c.vi_mode,
          c.git_branch,
          c.git_diff_added,
          c.git_diff_changed,
          c.git_diff_removed,
          c.file_info,
        },
        { -- right
          c.lsp_error,
          c.lsp_warn,
          c.lsp_info,
          c.lsp_hint,
          c.sep_warning,
          c.warning,
          c.file_type,
          c.file_encoding,
          c.position,
          c.line_percentage,
        },
      }

      local inactive = {
        {
          c.inactive,
          c.inactive_file_info,
        }, -- left
        {
          c.inactive_file_type,
          c.inactive_file_encoding,
          c.inactive_position,
          c.inactive_line_percentage,
        }, -- right
      }

      inactive = {
        { -- left
          c.inactive,
          c.git_branch,
          c.git_diff_added,
          c.git_diff_changed,
          c.git_diff_removed,
          c.file_info,
        },
        { -- right
          c.lsp_error,
          c.lsp_warn,
          c.lsp_info,
          c.lsp_hint,
          c.sep_warning,
          c.warning,
          c.file_type,
          c.file_encoding,
          c.position,
          c.line_percentage,
        },
      }

      require("feline").setup({
        components = { active = active, inactive = inactive },
        force_inactive = {
          filetypes = {
            "packer",
            "dap-repl",
            "dapui_scopes",
            "dapui_stacks",
            "dapui_watches",
            "dapui_repl",
            "LspTrouble",
            "qf",
            "help",
          },
          buftypes = { "terminal" },
          bufnames = {},
        },
        disable = {
          filetypes = {
            "NvimTree",
            "dashboard",
            "startify",
          },
        },
      })
    end,
  },

  {
    "Pocco81/TrueZen.nvim",
    config = function()
      local true_zen = require("true-zen")

      true_zen.setup {
      }
      local m = plugin_settings.truezen.mappings
      -- map <C-w>a to toogle Ataraxis Mode
      vim.api.nvim_set_keymap('', m.ataraxis, '<cmd>TZAtaraxis<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('i', m.ataraxis, '<cmd>TZAtaraxis<CR>', { noremap = true, silent = true })
      -- map <C-w>z to toogle Focus Mode
      vim.api.nvim_set_keymap('', m.focus, '<cmd>TZFocus<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('i', m.focus, '<cmd>TZFocus<CR>', { noremap = true, silent = true })
      -- map <C-w>m to toogle Minimalist Mode
      vim.api.nvim_set_keymap('', m.minimalist, '<cmd>TZMinimalist<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('i', m.minimalist, '<cmd>TZMinimalist<CR>', { noremap = true, silent = true })
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
      vim.keymap.set('n', '<c-w><enter>', ":Detour<cr>")
      vim.keymap.set('n', '<c-w>.', ":DetourCurrentWindow<cr>")
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

      vim.api.nvim_set_keymap('', '<C-w>h', "<cmd>lua require('detour.movements').DetourWinCmdH()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap('', '<C-w>l', "<cmd>lua require('detour.movements').DetourWinCmdL()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap('', '<C-w>j', "<cmd>lua require('detour.movements').DetourWinCmdJ()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap('', '<C-w>k', "<cmd>lua require('detour.movements').DetourWinCmdK()<CR>", { noremap = true, silent = true })

      vim.keymap.set('n', '<space>t', function()
        local terminal_buffer_found = false
        -- Check if we there are any existing terminal buffers.
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do -- iterate through all buffers
          if vim.api.nvim_buf_is_loaded(buf) then       -- only check loaded buffers
            if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
              terminal_buffer_found = true
            end
          end
        end

        require('detour').Detour()                      -- Open a detour popup
        if terminal_buffer_found then
          require('telescope.builtin').buffers({})    -- Open telescope prompt
          vim.api.nvim_feedkeys("term://", "n", true) -- populate prompt with "term://"
        else
          -- [OPTIONAL] Set the new window's current working directory to the directory of current file.
          -- You can remove this line if you would prefer to open terminals from the
          -- existing working directory.
          -- vim.cmd.lcd(vim.fn.expand("%:p:h"))
          -- Since there are no existing terminal buffers, open a new one.
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
      end)

      vim.keymap.set("n", '<space>p', function ()
        local ok = require('detour').Detour()  -- open a detour popup
        if not ok then
          return
        end

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
      end)

      vim.keymap.set("n", '<space>g', function ()
        local ok = require('detour').Detour()  -- open a detour popup
        if not ok then
          return
        end

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
      end)
    end
  },
})
