local M = require("config.defaults")

-- Merge with custom config (if exists)
local ok, custom = pcall(require, "custom.config")
if ok and type(custom) == "table" then
  M = vim.tbl_deep_extend("force", M, custom)
end

return M
