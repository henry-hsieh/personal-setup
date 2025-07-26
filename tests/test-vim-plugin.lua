local args = vim.fn.argv()
local plugin_name = args[1]:match("(.+)%..+$")
local existence = args[2]
local command = args[3]

-- load plugin
require("lazy").load({
  wait = true,
  show = false,
  plugins = {plugin_name},
  concurrency = 1
})
-- test existence
local ok = vim.fn.exists(existence)
if ok == 0 then
  print(string.format("Load %s fail: %s does not exist\n", plugin_name, existence))
  vim.cmd.cquit()
end
-- test command
local success, err = pcall(vim.cmd, command)
if not success then
  print(string.format("Run \"%s\" from %s fail: %s\n", command, plugin_name, err))
  vim.cmd.cquit()
end

print(string.format("Test %s pass\n", plugin_name))
