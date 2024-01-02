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

require("lazy").setup({
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
    },
    config = function()
      require('telescope').setup{
        defaults = {
          mappings = {
            i = {
              ["<C-x>"] = false,
              ["<C-s>"] = require('telescope.actions').select_horizontal,
              ["<C-v>"] = require('telescope.actions').select_vertical,

              ["<C-b>"] = require('telescope.actions').results_scrolling_up,
              ["<C-f>"] = require('telescope.actions').results_scrolling_down,

              ["<C-j>"] = require('telescope.actions').move_selection_next,
              ["<C-k>"] = require('telescope.actions').move_selection_previous,

              ["<C-Up>"]   = require('telescope.actions').preview_scrolling_up,
              ["<C-Down>"] = require('telescope.actions').preview_scrolling_down,
            },

            n = {
              ["<C-x>"] = false,
              ["<C-h>"] = require('telescope.actions').select_horizontal,
              ["<C-v>"] = require('telescope.actions').select_vertical,

              ["<C-b>"] = require('telescope.actions').results_scrolling_up,
              ["<C-f>"] = require('telescope.actions').results_scrolling_down,

              ["<C-j>"] = require('telescope.actions').move_selection_next,
              ["<C-k>"] = require('telescope.actions').move_selection_previous,

              ["<C-Up>"]   = require('telescope.actions').preview_scrolling_up,
              ["<C-Down>"] = require('telescope.actions').preview_scrolling_down,
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
    build = 'make CC=gcc',
  },

  {
    'kyazdani42/nvim-tree.lua',
    dependencies = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icon
    },
    config = function()
      local function my_on_attach(bufnr)
        local api = require "nvim-tree.api"

        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- custom mappings
        vim.keymap.set('n', '<C-s>', api.node.open.horizontal,        opts('Open: Horizontal Split'))
        vim.keymap.set('n', '?',     api.tree.toggle_help,            opts('Help'))
      end

      require'nvim-tree'.setup {
        on_attach = my_on_attach,
      }

      -- map F9 to toogle NvimTree and focus on current file
      vim.api.nvim_set_keymap('n', '<F9>', '<cmd>NvimTreeFindFileToggle!<CR>', { noremap = true, silent = true })
    end
  },

  {
    'phaazon/hop.nvim',
    branch = 'v1', -- optional but strongly recommended
    config = function()
      require'hop'.setup {
        keys = 'asdfghjkl;qwertyuiopzxcvbnm',
        char2_fallback_key = '<Esc>',
        multi_windows = true
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
              [",a"] = "@parameter.inner",
            },
            swap_previous = {
              [",A"] = "@parameter.inner",
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
    'williamboman/mason.nvim',
    branch = 'v2.x',
    config = function()
      require'mason'.setup{
        -- log_level = vim.log.levels.DEBUG,
        registries = {
            "github:henry-hsieh/mason-registry",
        },
      }
    end
  },

  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
    },
    config = function()
      local handlers = {
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.
        function (server_name) -- default handler (optional)
          require("lspconfig")[server_name].setup {}
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
                diagnostics = {
                  globals = { "vim" }
                }
              }
            }
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
    'henry-hsieh/mason-tool-installer.nvim',
    branch = 'add-sync',
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
      vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
      vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

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
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<space>f', function()
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

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          -- Actions
          map('n', ',hs', gs.stage_hunk)
          map('n', ',hr', gs.reset_hunk)
          map('v', ',hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
          map('v', ',hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
          map('n', ',hS', gs.stage_buffer)
          map('n', ',hu', gs.undo_stage_hunk)
          map('n', ',hR', gs.reset_buffer)
          map('n', ',hp', gs.preview_hunk)
          map('n', ',hb', function() gs.blame_line{full=true} end)
          map('n', ',ht', gs.toggle_current_line_blame)
          map('n', ',hd', gs.diffthis)
          map('n', ',hD', function() gs.diffthis('~') end)
          map('n', ',hT', gs.toggle_deleted)

          -- Text object
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end
      }
    end,
  },

  -- Completion and snippets
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/cmp-buffer'},
  {'hrsh7th/cmp-path'},
  {'hrsh7th/cmp-cmdline'},
  -- For vsnip users.
  -- {'hrsh7th/cmp-vsnip'},
  -- {'hrsh7th/vim-vsnip'},
  -- For luasnip users.
  {'L3MON4D3/LuaSnip'},
  {'saadparwaiz1/cmp_luasnip'},
  --
  -- For ultisnips users.
  -- {'SirVer/ultisnips'},
  -- {'quangnguyen30192/cmp-nvim-ultisnips'},
  --
  -- For snippy users.
  -- {'dcampos/nvim-snippy'},
  -- {'dcampos/cmp-snippy'},
  {
    'hrsh7th/nvim-cmp',
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
          ["<Tab>"] = cmp.mapping(function(fallback)
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

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),

        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          -- { name = 'vsnip' }, -- For vsnip users.
          { name = 'luasnip' }, -- For luasnip users.
          -- { name = 'ultisnips' }, -- For ultisnips users.
          -- { name = 'snippy' }, -- For snippy users.
        }, {
            { name = 'buffer' },
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
      require("luasnip").config.setup({store_selection_keys="s"})
    end
  },

  {
    'base16-project/base16-vim',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      vim.cmd([[let base16colorspace=256]])
      vim.cmd([[source ~/.vimrc_background]])
      vim.cmd([[hi link TSKeywordOperator Keyword]])
    end,
  },

  {
    'feline-nvim/feline.nvim',
    dependencies = {
      'base16-project/base16-vim',
    },
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
        size = 0
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
          hl.fg = vim.g['base16_gui' .. fmt("%02X", fg)] and "#" .. vim.g['base16_gui' .. fmt("%02X", fg)] or vim.g.terminal_color_foreground
        end
        if bg then
          hl.bg = vim.g['base16_gui' .. fmt("%02X", bg)] and "#" .. vim.g['base16_gui' .. fmt("%02X", bg)] or vim.g.terminal_color_background
        end
        if style then
          hl.style = style
        end
        return hl
      end

      local vi_mode_colors = {
        ['NORMAL']    = base16_hl(0,11,'bold'),
        ['OP']        = base16_hl(0,11,'bold'),
        ['INSERT']    = base16_hl(1,13,'bold'),
        ['VISUAL']    = base16_hl(1,14,'bold'),
        ['LINES']     = base16_hl(1,14,'bold'),
        ['BLOCK']     = base16_hl(1,14,'bold'),
        ['REPLACE']   = base16_hl(1, 8,'bold'),
        ['V-REPLACE'] = base16_hl(1, 8,'bold'),
        ['ENTER']     = base16_hl(1,12,'bold'),
        ['MORE']      = base16_hl(1,12,'bold'),
        ['SELECT']    = base16_hl(1, 9,'bold'),
        ['COMMAND']   = base16_hl(0,11,'bold'),
        ['SHELL']     = base16_hl(0,11,'bold'),
        ['TERM']      = base16_hl(0,11,'bold'),
        ['NONE']      = base16_hl(1,10,'bold'),
      }

      local vi_sep_colors = {
        ['NORMAL']    = base16_hl(11,1,'bold'),
        ['OP']        = base16_hl(11,1,'bold'),
        ['INSERT']    = base16_hl(13,1,'bold'),
        ['VISUAL']    = base16_hl(14,1,'bold'),
        ['LINES']     = base16_hl(14,1,'bold'),
        ['BLOCK']     = base16_hl(14,1,'bold'),
        ['REPLACE']   = base16_hl( 8,1,'bold'),
        ['V-REPLACE'] = base16_hl( 8,1,'bold'),
        ['ENTER']     = base16_hl(12,1,'bold'),
        ['MORE']      = base16_hl(12,1,'bold'),
        ['SELECT']    = base16_hl( 9,1,'bold'),
        ['COMMAND']   = base16_hl(11,1,'bold'),
        ['SHELL']     = base16_hl(11,1,'bold'),
        ['TERM']      = base16_hl(11,1,'bold'),
        ['NONE']      = base16_hl(10,1,'bold'),
      }

      local function vi_mode_hl()
        return vi_mode_colors[require("feline.providers.vi_mode").get_vim_mode()] or vi_mode_colors['NONE']
      end

      local function vi_sep_hl()
        return vi_sep_colors[require("feline.providers.vi_mode").get_vim_mode()] or vi_sep_colors['NONE']
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
          hl = vi_mode_hl,
          right_sep = { str = "", hl = vi_sep_hl},
        },
        git_branch = {
          provider = "git_branch",
          icon = "  ",
          hl = base16_hl(4, 1,'None'),
          right_sep = { str = " ", hl = base16_hl(4, 1,'None') },
          enabled = function()
            return vim.b.gitsigns_status_dict ~= nil
          end,
        },
        git_diff_added = {
          provider = "git_diff_added",
          icon = " ",
          hl = base16_hl(11, 1,'None'),
          right_sep = { str = " ", hl = base16_hl(4, 1,'None') },
          enabled = function()
            return vim.b.gitsigns_status_dict ~= nil
          end,
        },
        git_diff_changed = {
          provider = "git_diff_changed",
          icon = " ",
          hl = base16_hl(9, 1,'None'),
          right_sep = { str = " ", hl = base16_hl(4, 1,'None') },
          enabled = function()
            return vim.b.gitsigns_status_dict ~= nil
          end,
        },
        git_diff_removed = {
          provider = "git_diff_removed",
          icon = " ",
          hl = base16_hl(8, 1,'None'),
          right_sep = { str = " ", hl = base16_hl(4, 1,'None') },
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
          hl = base16_hl(6, 2,'None'),
          left_sep = { str = " ", hl = base16_hl(1, 2,'None') },
          right_sep = {
            str = function()
              if vim.bo.modified then
                return ""
              else
                return "█"
              end
            end,
            hl = base16_hl(2, 1,'None'),
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
          hl = base16_hl(6, 2,'None'),
          right_sep = { str = "", hl = base16_hl(1, 2,'None') },
        },
        file_type = {
          provider = function()
            return fmt(" %s ", vim.bo.filetype)
          end,
          hl = base16_hl(6, 2, "None"),
          right_sep = { str = " ", hl = base16_hl(6, 2,'None') },
          left_sep = { str = "", hl = base16_hl(2, 10, "None") },
        },
        warning = {
          provider = function()
            str = ''
            if vim.fn.getfsize(vim.fn.expand('%:p')) < 10485760 then -- 10MB
              -- Mixed indent
              c_like_langs = {'arduino', 'c', 'cpp', 'cuda', 'go', 'javascript', 'ld', 'php' ,'verilog', 'systemverilog'}
              if index(c_like_langs, vim.o.ft) > 0 then
                head_space = '\\v(^ +\\*@!)'
              else
                head_space = '\\v(^ +)'
              end
              indent_tabs = vim.fn.search('\\v(^\\t+)', 'nw', 0 ,150)
              indent_spaces = vim.fn.search(head_space, 'nw', 0 ,150)
              if indent_tabs > 0 and indent_spaces > 0 then
                str = "  " .. fmt("%d:%d", indent_tabs, indent_spaces) .. str
              end

              -- Trailing spaces or tabs
              trailing = vim.fn.search('\\s$', 'nw', 0 ,150)
              if trailing > 0 then
                str = " 󱁐 " .. fmt("%d", trailing) .. str
              end

              -- Git conflicts
              if vim.b.gitsigns_status_dict ~= nil then
                annotation = '\\%([0-9A-Za-z_.:]\\+\\)\\?'
                rst_like_langs = {'rst', 'markdown'}
                if index(rst_like_langs, vim.o.ft) > 0 then
                  pattern = '^\\%(\\%(<\\{7} ' .. annotation .. '\\)\\|\\%(>\\{7\\} ' .. annotation .. '\\)\\)$'
                else
                  pattern = '^\\%(\\%(<\\{7} ' .. annotation .. '\\)\\|\\%(=\\{7\\}\\)\\|\\%(>\\{7\\} ' .. annotation .. '\\)\\)$'
                end
                conflicts = vim.fn.search(pattern, "nw", 0, 200)
                if conflicts > 0 then
                  str = "  " .. fmt("%d", conflicts) .. str
                end
              end
            end
            return str
          end,
          hl = base16_hl(1, 10,'None'),
          right_sep = { str = " ", hl = base16_hl(1, 10,'None') },
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
          hl = vi_mode_hl,
          left_sep = { str = "█", hl = vi_sep_hl },
        },
        line_percentage = {
          provider = function()
            return "%p%% "
          end,
          icon = " ",
          hl = vi_mode_hl,
        },
        lsp_error = {
          provider = function()
            return get_diag("ERROR")
          end,
          hl = base16_hl(1, 8, 'None'),
          left_sep = { str = "", hl = base16_hl(8, 1, 'None'), always_visible = true },
          enabled = function()
            return require("feline.providers.lsp").is_lsp_attached()
          end,
        },
        lsp_warn = {
          provider = function()
            return get_diag("WARN")
          end,
          hl = base16_hl(1, 9, 'None'),
          left_sep = { str = "", hl = base16_hl(9, 8, 'None'), always_visible = true },
          enabled = function()
            return require("feline.providers.lsp").is_lsp_attached()
          end,
        },
        lsp_info = {
          provider = function()
            return get_diag("INFO")
          end,
          hl = base16_hl(1, 13, 'None'),
          left_sep = { str = "", hl = base16_hl(13, 9, 'None'), always_visible = true },
          enabled = function()
            return require("feline.providers.lsp").is_lsp_attached()
          end,
        },
        lsp_hint = {
          provider = function()
            return get_diag("HINT")
          end,
          hl = base16_hl(1, 12, 'None'),
          left_sep = { str = "", hl = base16_hl(12, 13, 'None'), always_visible = true },
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
          hl = base16_hl(4, 1, "None"),
          right_sep = { str = " ", hl = base16_hl(4, 1, "None")},
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
          hl = base16_hl(4, 2,'None'),
          left_sep = { str = " ", hl = base16_hl(1, 2,'None') },
          right_sep = {
            str = function()
              if vim.bo.modified then
                return ""
              else
                return "█"
              end
            end,
            hl = base16_hl(2, 1,'None'),
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
          hl = base16_hl(4, 2,'None'),
          right_sep = { str = "", hl = base16_hl(1, 2,'None') },
        },
        inactive_file_type = {
          provider = function()
            return fmt(" %s ", vim.bo.filetype)
          end,
          hl = base16_hl(4, 2, "None"),
          right_sep = { str = " ", hl = base16_hl(4, 2,'None') },
          left_sep = { str = "", hl = base16_hl(2, 1, "None") },
        },
        inactive_position = {
          provider = {
            name = "position",
            opts = {
              format = "{line} {col} ",
            },
          },
          hl = base16_hl(4, 1, "None"),
          left_sep = { str = "  ", hl = base16_hl(4, 1, "None") },
        },
        inactive_line_percentage = {
          provider = function()
            return "%p%% "
          end,
          icon = " ",
          hl = base16_hl(4, 1, "None"),
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

      require("feline").setup({
        components = { active = active, inactive = inactive },
        highlight_reset_triggers = {},
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
      -- map <C-w>a to toogle Ataraxis Mode
      vim.api.nvim_set_keymap('', '<C-w>a', '<cmd>TZAtaraxis<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('i', '<C-w>a', '<cmd>TZAtaraxis<CR>', { noremap = true, silent = true })
      -- map <C-w>z to toogle Focus Mode
      vim.api.nvim_set_keymap('', '<C-w>z', '<cmd>TZFocus<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('i', '<C-w>z', '<cmd>TZFocus<CR>', { noremap = true, silent = true })
      -- map <C-w>m to toogle Minimalist Mode
      vim.api.nvim_set_keymap('', '<C-w>m', '<cmd>TZMinimalist<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('i', '<C-w>m', '<cmd>TZMinimalist<CR>', { noremap = true, silent = true })
    end,
  },

  {
    "henry-hsieh/riscv-asm-vim",
    config = function()
      vim.g.riscv_asm_isa = 'RV64GCV_Ss_Sm'
      vim.g.riscv_asm_debug = true
      vim.g.riscv_asm_all_enable = true -- undefined to enable ISA parsing
    end,
  },

  {"tpope/vim-fugitive"},
})
