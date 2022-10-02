local M = {}

M.name = "journal-lsp"
M.filetypes = { "markdown", "telekasten" }
M.enabled = false

M.setup = function()
	require("journal-lsp.globals")

	-- 1. is it md file?
	if not CE(M.filetypes, vim.bo.filetype) then
		return
	end

	-- 2. is it 'journal' dir?
	local root_dir = (vim.fs.dirname(vim.fs.find({
		"index.md",
		"README.md",
	}, { upward = true })[1]))
	if root_dir then
		M.root_dir = root_dir
		M.enabled = true
	else
		return
	end

	-- 3. is it 'daily' or 'weekly' note?
	local s = vim.fs.basename(vim.api.nvim_buf_get_name(0))
	local date = "%d+-%d+-%d+.md"
	if not (string.find(s, date) == nil) then
		-- get the date
		local _, _, y, m, d = string.find(s, "(%d+)-(%d+)-(%d+).md")

		-- TODO: get yesterday and tomorrow
		local _current = y .. "-" .. m .. "-" .. d

		local _past = vim.api.nvim_command_output("!ls " .. root_dir .. "/daily | grep " .. _current .. " -B 1")
		_past = vim.split(_past, "\n")[3]

		local _future = vim.api.nvim_command_output("!ls " .. root_dir .. "/daily | grep " .. _current .. " -A 1")
		_future = vim.split(_future, "\n")[4]

		vim.notify("Past -> " .. _past)
		vim.notify("Current -> " .. _current)
		vim.notify("Future -> " .. _future)
	end

	-- 4. init
	vim.schedule(function()
		vim.notify("journal-lsp started")
	end)
	local actions = require("journal-lsp.actions")

	M.files = function()
		actions.find_files(M.root_dir, "~ files ~")
	end

	M.daily = function()
		actions.find_files(M.root_dir .. "/daily", "~ daily ~")
	end

	M.weekly = function()
		actions.find_files(M.root_dir .. "/weekly", "~ weekly ~")
	end

	M.add_note = function()
		actions.add_note()
	end

	M.goto_link = function()
		actions.goto_link()
	end

	M.goto_today = function()
		actions.goto_today()
	end

	M.goto_past = function()
		-- 3. is it 'daily' or 'weekly' note?
		s = vim.fs.basename(vim.api.nvim_buf_get_name(0))
		date = "%d+-%d+-%d+.md"
		if not (string.find(s, date) == nil) then
			local _, _, y, m, d = string.find(s, "(%d+)-(%d+)-(%d+).md")
			local _current = y .. "-" .. m .. "-" .. d
			local _past = vim.api.nvim_command_output("!ls " .. root_dir .. "/daily | grep " .. _current .. " -B 1")
			_past = vim.split(_past, "\n")[3]
			if _past then
				actions.goto_date(M.root_dir, _past)
			end
		end
	end

	M.goto_future = function()
		-- 3. is it 'daily' or 'weekly' note?
		s = vim.fs.basename(vim.api.nvim_buf_get_name(0))
		date = "%d+-%d+-%d+.md"
		if not (string.find(s, date) == nil) then
			local _, _, y, m, d = string.find(s, "(%d+)-(%d+)-(%d+).md")
			local _current = y .. "-" .. m .. "-" .. d
			local _future = vim.api.nvim_command_output("!ls " .. root_dir .. "/daily | grep " .. _current .. " -A 1")
			_future = vim.split(_future, "\n")[4]
			if _future then
				actions.goto_date(M.root_dir, _future)
			end
		end
	end

	local nmappings = {
		["<C-a>f"] = "files()",
		["<C-a>d"] = "daily()",
		["<C-a>w"] = "weekly()",
		["<C-a>g"] = "goto_link()",
		["<C-a>t"] = "goto_today()",
		["<C-Up>"] = "goto_past()",
		["<C-Down>"] = "goto_future()",
	}

	local imappings = {
		["<C-a>i"] = "add_note()",
	}

	for k, v in pairs(nmappings) do
		vim.api.nvim_set_keymap("n", k, ':lua require"journal-lsp".' .. v .. "<cr>", {
			noremap = true,
			silent = true,
		})
	end

	for k, v in pairs(imappings) do
		vim.api.nvim_set_keymap("i", k, '<Esc>:lua require"journal-lsp".' .. v .. "<cr>a", {
			noremap = true,
			silent = true,
		})
	end
end

return M
