local M = {}

function M.shell_error()
  return vim.v.shell_error ~= 0
end

function M._echo_multiline(msg)
  for _, s in ipairs(vim.fn.split(msg, "\n")) do
    vim.cmd("echom '" .. s:gsub("'", "''").."'")
  end
end

function M.info(msg)
  vim.cmd('echohl Directory')
  M._echo_multiline(msg)
  vim.cmd('echohl None')
end

function M.dump_table(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. M.dump_table(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function M.cur_file_path()
    return vim.fn.expand('%:p')
end

function M.cur_file_dir()
    return vim.fn.expand('%:p:h')
end

function M.git_cwd(cmd, cwd)
  if not cwd then return cmd end
  cwd = vim.fn.expand(cwd)
  local arg_cwd = ("-C %s "):format(vim.fn.shellescape(cwd))
  cmd = cmd:gsub("^git ", "git " ..  arg_cwd)
  return cmd
end

function M.git_root(cwd, noerr)
  local cmd = M.git_cwd("git rev-parse --show-toplevel", cwd)
  local output = vim.fn.systemlist(cmd)
  if M.shell_error() then
    if not noerr then M.info(unpack(output)) end
    return nil
  end
  return output[1]
end

function M.git_superproject(cwd, noerr)
  local cmd = M.git_cwd("git rev-parse --show-superproject-working-tree", cwd)
  local output = vim.fn.systemlist(cmd)
  if M.shell_error() then
    if not noerr then M.info(unpack(output)) end
    return nil
  end
  if output[1] == nil then
      return M.git_root(cwd, noerr)
  else
      return output[1]
  end
end

function M.is_git_repo(cwd, noerr)
  return not not M.git_root(cwd, noerr)
end

function M.exec_nvim_cmd(command)
  local parsed_command = vim.api.nvim_parse_cmd(command, {})
  -- Execute the command
  local output = vim.api.nvim_cmd(parsed_command, {output = true})
  return output
end

function M.exec_shell_cmd(command)
  return M.exec_nvim_cmd('!' .. command)
end

function M.file_exists(filepath)
  local stat = vim.loop.fs_stat(filepath)
  return stat and stat.type == 'file'
end

-- Extract RGB from hex
---@param color string string with #RRGGBB format
---@return integer r
---@return integer g
---@return integer b
local function hex_to_rgb(color)
  local r = tonumber(color:sub(2, 3), 16)
  local g = tonumber(color:sub(4, 5), 16)
  local b = tonumber(color:sub(6, 7), 16)
  return r, g, b
end

-- Encode RGB to hex
---@param r integer
---@param g integer
---@param b integer
---@return string color string with #RRGGBB format
local function rgb_to_hex(r, g, b)
  return string.format("#%02x%02x%02x", r, g, b)
end

-- Adjust brightness of given color with specified ratio
---@param color string string with #RRGGBB format
---@param ratio number multiplier of the color
---@return string adjusted_color string with #RRGGBB format
function M.adjust_brightness(color, ratio)
  local r, g, b = hex_to_rgb(color)

  r = math.floor(math.min(255, math.max(0, r * ratio)))
  g = math.floor(math.min(255, math.max(0, g * ratio)))
  b = math.floor(math.min(255, math.max(0, b * ratio)))

  return rgb_to_hex(r, g, b)
end

-- Mixed two given colors with specified ratio
---@param color1 string string with #RRGGBB format
---@param color2 string string with #RRGGBB format
---@param ratio number|nil ratio of the color1
---@return string mixed_color string with #RRGGBB format
function M.mix_color(color1, color2, ratio)
  local r1, g1, b1 = hex_to_rgb(color1)
  local r2, g2, b2 = hex_to_rgb(color2)

  local ratio1 = ratio or 0.5
  local ratio2 = 1 - ratio1

  local r = math.floor(math.min(255, math.max(0, r1 * ratio1 + r2 * ratio2)))
  local g = math.floor(math.min(255, math.max(0, g1 * ratio1 + g2 * ratio2)))
  local b = math.floor(math.min(255, math.max(0, b1 * ratio1 + b2 * ratio2)))

  return rgb_to_hex(r, g, b)
end

return M
