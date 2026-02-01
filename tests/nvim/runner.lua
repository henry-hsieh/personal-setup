-- Nvim Test Runner
-- Uses plenary.busted to run tests defined in manifest.lua

local manifest = require("tests.nvim.manifest")
local lazy = require("lazy")

describe("Neovim Configuration and Plugins", function()

  describe("Config Modules", function()
    for _, mod in ipairs(manifest.config_modules) do
      it("should load " .. mod, function()
        local ok, err = pcall(require, mod)
        assert.is_true(ok, "Failed to load " .. mod .. ": " .. tostring(err))
      end)
    end
  end)

  describe("Plugins", function()
    for _, plugin in ipairs(manifest.plugins) do
      describe(plugin.name, function()
        local modes = plugin.modes or { "load" }

        for _, mode in ipairs(modes) do
          if mode == "load" then
            it("should load via lazy.nvim", function()
              lazy.load({ plugins = { plugin.name } })
              -- Check if plugin directory is in rtp or if it's loaded
              local config = require("lazy.core.config")
              local p = config.plugins[plugin.name]
              assert.is_not_nil(p, "Plugin " .. plugin.name .. " not found in lazy.nvim")
              assert.is_truthy(p._.loaded, "Plugin " .. plugin.name .. " failed to load")
            end)
          elseif mode == "health" then
            it("should pass health check", function()
              vim.cmd("checkhealth " .. plugin.name)
            end)
          elseif mode == "call" then
            it("should call " .. plugin.call.fn, function()
              lazy.load({ plugins = { plugin.name } })

              local parts = vim.split(plugin.call.fn, "%.")
              local current = _G

              -- Robust resolution of the function path
              for i = 1, #parts - 1 do
                local part = parts[i]
                if current[part] then
                  current = current[part]
                else
                  -- Try requiring the module path up to this point
                  local mod_name = table.concat(parts, ".", 1, i)
                  local ok, mod = pcall(require, mod_name)
                  if ok then
                    current = mod
                  else
                    -- Fallback: try requiring the part itself if it's a common module name
                    ok, mod = pcall(require, part)
                    if ok then
                      current = mod
                    else
                      error("Could not find or require " .. mod_name)
                    end
                  end
                end
              end

              local fn = current[parts[#parts]]
              assert.is_function(fn, "Function " .. plugin.call.fn .. " not found")
              local ok, err = pcall(fn, unpack(plugin.call.args or {}))
              assert.is_true(ok, "Call to " .. plugin.call.fn .. " failed: " .. tostring(err))
            end)
          elseif mode == "vim-plugin" then
            it("should load vim plugin and run command", function()
              lazy.load({ plugins = { plugin.name } })
              -- Set filetype if plugin requires it (some commands only exist for specific filetypes)
              if plugin.trigger and plugin.trigger.ft then
                vim.api.nvim_command("set filetype=" .. plugin.trigger.ft)
              end
              assert.is_true(vim.fn.exists(plugin.vim_plugin.exists) ~= 0, "Plugin " .. plugin.name .. " failed to load: " .. plugin.vim_plugin.exists .. " not found")
              local ok, err = pcall(vim.cmd, plugin.vim_plugin.cmd)
              assert.is_true(ok, "Command " .. plugin.vim_plugin.cmd .. " failed: " .. tostring(err))
            end)
          elseif mode == "trigger" then
            it("should load on " .. (plugin.trigger.event or plugin.trigger.ft or "trigger"), function()
              if plugin.trigger.event then
                vim.cmd("doautocmd " .. plugin.trigger.event)
              end
              if plugin.trigger.ft then
                vim.api.nvim_command("set filetype=" .. plugin.trigger.ft)
              end

              local config = require("lazy.core.config")
              local p = config.plugins[plugin.name]
              assert.is_not_nil(p, "Plugin " .. plugin.name .. " not found in lazy.nvim")
              assert.is_truthy(p._.loaded, "Plugin " .. plugin.name .. " failed to load on trigger")
            end)
          end
        end
      end)
    end
  end)

  describe("Treesitter Parsers", function()
    for _, lang in ipairs(manifest.ts_parsers) do
      it("should load " .. lang .. " parser", function()
        local ok, _ = pcall(vim.treesitter.language.add, lang)
        assert.is_true(ok, "Failed to load treesitter parser for " .. lang)
      end)
    end
  end)

end)
