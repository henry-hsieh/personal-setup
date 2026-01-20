return {
  {
    'lewis6991/gitsigns.nvim',
    event = 'LazyFile',
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        local m = require("config").git.mappings
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
}
