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

return M
