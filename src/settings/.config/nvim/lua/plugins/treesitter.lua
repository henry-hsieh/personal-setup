return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = function()
      local opts = require("config.treesitter")
      local langs = {}
      local insert = table.insert

      for lang, _ in pairs(opts) do
        insert(langs, lang)
      end

      require("nvim-treesitter").install(langs):wait(10 * 60 * 1000)
      require("nvim-treesitter").update(langs):wait(10 * 60 * 1000)
    end,
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
    end,
    keys = {
      {
        "<c-space>",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter({
            actions = {
              ["<c-space>"] = "next",
              ["<BS>"] = "prev"
            }
          })
        end,
        desc = "Treesitter incremental selection"
      },
    },
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
              { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
              { text = { "%s" }, click = "v:lua.ScSa" },
              { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" }
            }
          }
        end,
      }
    },
    event = 'LazyFile',
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
      { "zR", mode = { "n" }, function() require('ufo').openAllFolds() end, desc = "Open all folds" },
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
}
