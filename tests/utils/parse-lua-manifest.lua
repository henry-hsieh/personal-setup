#!/usr/bin/env lua
-- Parses a Lua manifest file and outputs package names (one per line).
-- Usage: lua parse-lua-manifest.lua <manifest_path>

local function main()
	local manifest_path = arg[1]
	if not manifest_path then
		io.stderr:write("Usage: lua parse-lua-manifest.lua <manifest_path>\n")
		os.exit(1)
	end

	local chunk, err = loadfile(manifest_path)
	if not chunk then
		io.stderr:write("Failed to load manifest: " .. err .. "\n")
		os.exit(1)
	end

	local ok, manifest = pcall(chunk)
	if not ok then
		io.stderr:write("Failed to execute manifest: " .. manifest .. "\n")
		os.exit(1)
	end

	if type(manifest) ~= "table" then
		io.stderr:write("Manifest must return a table\n")
		os.exit(1)
	end

	local names = {}

	-- Extract plugin names
	if type(manifest.plugins) == "table" then
		for _, plugin in ipairs(manifest.plugins) do
			if type(plugin) == "table" and type(plugin.name) == "string" then
				names[plugin.name] = true
			end
		end
	end

	-- Extract config_modules
	if type(manifest.config_modules) == "table" then
		for _, mod in ipairs(manifest.config_modules) do
			if type(mod) == "string" then
				names[mod] = true
			end
		end
	end

	-- Extract ts_parsers
	if type(manifest.ts_parsers) == "table" then
		for _, parser in ipairs(manifest.ts_parsers) do
			if type(parser) == "string" then
				names[parser] = true
			end
		end
	end

	-- Output sorted names
	local sorted = {}
	for name in pairs(names) do
		table.insert(sorted, name)
	end
	table.sort(sorted)

	for _, name in ipairs(sorted) do
		print(name)
	end
end

main()
