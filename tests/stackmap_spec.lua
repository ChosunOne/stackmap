local find_map = function(lhs)
	local maps = vim.api.nvim_get_keymap("n")
	for _, map in ipairs(maps) do
		if map.lhs == lhs then
			return map
		end
	end
end

describe("stackmap", function()
	before_each(function()
		require("stackmap")._clear()
		pcall(vim.keymap.del, "n", "asdf")
		pcall(vim.keymap.del, "n", "asdf1")
		pcall(vim.keymap.del, "n", "asdf2")
	end)
	it("can be required", function()
		require("stackmap")
	end)

	it("can push a single mapping", function()
		local rhs = "echo 'This is a test'"
		require("stackmap").push("test1", "n", {
			asdf = rhs,
		})

		local found = find_map("asdf")
		assert.are.same(rhs, found.rhs)
	end)

	it("can push multiple mappings", function()
		local rhs = "echo 'This is a test'"
		require("stackmap").push("test1", "n", {
			asdf1 = rhs .. "1",
			asdf2 = rhs .. "2",
		})

		local found = find_map("asdf1")
		assert.are.same(rhs .. "1", found.rhs)
		local found = find_map("asdf2")
		assert.are.same(rhs .. "2", found.rhs)
	end)

	it("can delete mappings after pop not existing", function()
		local rhs = "echo 'This is a test'"
		require("stackmap").push("test1", "n", {
			asdf = rhs,
		})

		local found = find_map("asdf")
		assert.are.same(rhs, found.rhs)

		require("stackmap").pop("test1", "n")
		local after_pop = find_map("test1")
		assert.are.same(nil, after_pop)
	end)

	it("can delete mappings after pop existing", function()
		vim.keymap.set("n", "asdf", "echo 'OG MAPPING'")
		local rhs = "echo 'This is a test'"
		require("stackmap").push("test1", "n", {
			asdf = rhs,
		})

		local found = find_map("asdf")
		assert.are.same(rhs, found.rhs)

		require("stackmap").pop("test1", "n")
		local after_pop = find_map("asdf")
		assert.are.same("echo 'OG MAPPING'", after_pop.rhs)
	end)
end)
