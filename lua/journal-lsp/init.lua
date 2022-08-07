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
		print(y, m, d)
		print(M.root_dir)

		-- TODO: get yesterday and tomorrow
		M._yesterday = y .. "-" .. m .. "-" .. y .. ".md"
		M._tomorrow = y .. "-" .. m .. "-" .. y .. ".md"
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

	M.goto_link = function()
		actions.goto_link()
	end

	local mappings = {
		["<C-a>f"] = "files()",
		["<C-a>d"] = "daily()",
		["<C-a>w"] = "weekly()",
	}

	for k, v in pairs(mappings) do
		vim.api.nvim_set_keymap("n", k, ':lua require"journal-lsp".' .. v .. "<cr>", {
			noremap = true,
			silent = true,
		})
	end
end

return M
