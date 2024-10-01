local M = {}

M.setup = function(opts) end

-- functions we need
-- - vim.keymap.set(...) -> create new keymaps
-- - vim.api.nvim_get_keymap -> get keymaps

local find_mapping = function(maps, lhs)
	for _, value in ipairs(maps) do
		if value.lhs == lhs then
			return value
		end
	end
end

M.push = function(name, mode, mappings)
	local maps = vim.api.nvim_get_keymap(mode)
	local existing_maps = {}
	for lhs, rhs in pairs(mappings) do
		local existing = find_mapping(maps, lhs)
		if existing then
			existing_maps[lhs] = existing
		end
	end

	M._stack[name] = M._stack[name] or {}
	M._stack[name][mode] = {
		existing = existing_maps,
		mappings = mappings,
	}

	for lhs, rhs in pairs(mappings) do
		-- TODO: Need to pass in options here
		vim.keymap.set(mode, lhs, rhs)
	end
end

M.pop = function(name, mode)
	local state = M._stack[name][mode]
	M._stack[name][mode] = nil

	for lhs in pairs(state.mappings) do
		if state.existing[lhs] then
			-- handle mappings that existed
			local existing_mapping = state.existing[lhs]
			-- TODO: Handle the options from the table
			vim.keymap.set(mode, lhs, existing_mapping.rhs)
		else
			-- handle mappings that didn't exist
			vim.keymap.del(mode, lhs)
		end
	end
end

M._stack = {}

M._clear = function()
	M._stack = {}
end

-- [[
-- lua require("stackmap").push("debug_mode", "n", {
-- ["<leader>st"] = "echo 'Hello'",
-- ["<leader>sz"] = "echo 'Goodbye'",
-- })
-- ...
-- lua require("stackmap").pop("debug_mode")
-- ]]

return M
