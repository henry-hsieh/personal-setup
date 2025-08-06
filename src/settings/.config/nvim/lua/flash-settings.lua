-- flash-settings.lua
local M = {}
function M.jump_regex(regex)
  local Flash = require("flash")

  ---@param opts Flash.Format
  local function format(opts)
    -- always show first and second label
    return {
      { opts.match.label1, "FlashLabel" },
      { opts.match.label2, "FlashMatch" },
    }
  end

  ---@param opts Flash.Format
  local function format2(opts)
    return {
      { opts.match.label2, "FlashLabel" },
    }
  end

  Flash.jump({
    search = { mode = "search" },
    label = { after = false, before = { 0, 0 }, uppercase = false, format = format },
    pattern = regex,
    action = function(match, state)
      state:hide()
      Flash.jump({
        search = { max_length = 0 },
        highlight = { matches = false },
        label = { after = false, before = { 0, 0 }, format = format2 },
        matcher = function(win)
          -- limit matches to the current label
          return vim.tbl_filter(function(m)
            return m.label == match.label and m.win == win
          end, state.results)
        end,
        labeler = function(matches)
          for _, m in ipairs(matches) do
            m.label = m.label2         -- use the second label
          end
        end,
        prompt = {
          enabled = false,
        },
      })
    end,
    labeler = function(matches, state)
      local labels = state:labels()
      for m, match in ipairs(matches) do
        match.label1 = labels[math.floor((m - 1) / #labels) + 1]
        match.label2 = labels[(m - 1) % #labels + 1]
        match.label = match.label1
      end
    end,
    prompt = {
      enabled = false,
    },
  })
end

return M
