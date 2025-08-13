local opts = require("config.treesitter")
local langs = {}
local insert = table.insert

for lang, _ in pairs(opts) do
  insert(langs, lang)
end

require("nvim-treesitter").install(langs):wait(10*60*1000)
