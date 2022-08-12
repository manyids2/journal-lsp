local ff = {}

local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

ff.find_files = function(opts)
	local find_command = (function()
		if opts.find_command then
			if type(opts.find_command) == "function" then
				return opts.find_command(opts)
			end
			return opts.find_command
		elseif 1 == vim.fn.executable("rg") then
			return { "rg", "--files" }
		elseif 1 == vim.fn.executable("fd") then
			return { "fd", "--type", "f" }
		elseif 1 == vim.fn.executable("fdfind") then
			return { "fdfind", "--type", "f" }
		end
	end)()

	if not find_command then
		vim.notify("builtin.find_files", {
			msg = "You need to install either fdfind, fd, or rg",
			level = "ERROR",
		})
		return
	end

	local command = find_command[1]
	local hidden = opts.hidden
	local no_ignore = opts.no_ignore
	local no_ignore_parent = opts.no_ignore_parent
	local follow = opts.follow
	local search_file = opts.search_file

	if command == "fd" or command == "fdfind" or command == "rg" then
		if hidden then
			table.insert(find_command, "--hidden")
		end
		if no_ignore then
			table.insert(find_command, "--no-ignore")
		end
		if no_ignore_parent then
			table.insert(find_command, "--no-ignore-parent")
		end
		if follow then
			table.insert(find_command, "-L")
		end
		if search_file then
			if command == "rg" then
				table.insert(find_command, "-g")
				table.insert(find_command, "*" .. search_file .. "*")
			else
				table.insert(find_command, search_file)
			end
		end
	end

	if opts.cwd then
		opts.cwd = vim.fn.expand(opts.cwd)
	end

	pickers
		.new(opts, {
			prompt_title = "Find Files",
			finder = finders.new_oneshot_job(find_command, opts),
			previewer = conf.file_previewer(opts),
			sorter = conf.file_sorter(opts),
		})
		:find()
end

return ff
