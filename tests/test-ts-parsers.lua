local opts = require("config.treesitter")
local ts_add = vim.treesitter.language.add

for lang, _ in pairs(opts) do
  local ok, err = ts_add(lang)
  if not ok then
    print(string.format("Load treesiter parser %s fail: %s\n", lang, err))
    vim.cmd.cquit()
  end
end
