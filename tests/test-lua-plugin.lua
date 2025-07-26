local args = vim.fn.argv()
local plugin_name = args[1]:match("(.+)%..+$")
local module_name = args[2]
local function_name = args[3]
local arguments = args[4] or false

-- load plugin
require("lazy").load({
  wait = true,
  show = false,
  plugins = { plugin_name },
  concurrency = 1
})
-- test module
local ok, mod_or_err = pcall(require, module_name)
if not ok then
  print(string.format("Load %s fail: %s\n", plugin_name, mod_or_err))
  vim.cmd.cquit()
end
-- test function

--- Get a function from a module by dotted path string
--- e.g., get_function(mod, "a.b.c") == mod.a.b.c
local function get_function(mod, dotted_path)
  local parts = {}
  for part in string.gmatch(dotted_path, "[^%.]+") do
    table.insert(parts, part)
  end

  local fn = mod
  for i, key in ipairs(parts) do
    fn = fn[key]
    if fn == nil then
      print(string.format("Invalid path: '%s' (missing '%s')\n", dotted_path, key))
      vim.cmd.cquit()
    end
  end

  if type(fn) ~= "function" then
    print(string.format("Target at '%s' is not a function\n", dotted_path))
    vim.cmd.cquit()
  end

  return fn
end

local fn = get_function(mod_or_err, function_name)

-- Get arguments table
if arguments then
  local arguments_str = arguments
  local func, err = loadstring("return " .. arguments_str)

  if err then
    print(string.format("Error parsing string: %s\n", arguments_str))
    vim.cmd.cquit()
  end

  arguments = func()
end

local success, err
table.unpack = table.unpack or unpack
if arguments then
  success, err = pcall(fn, table.unpack(arguments))
else
  success, err = pcall(fn)
end

if not success then
  print(string.format("Run %s() from %s fail: %s\n", function_name, plugin_name, err))
  vim.cmd.cquit()
end

print(string.format("Test %s pass\n", plugin_name))
