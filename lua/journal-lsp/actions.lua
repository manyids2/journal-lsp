require("journal-lsp.globals")

local actions = {}

function actions.find_files(root_dir, title)
	local opts_with_preview, opts_without_preview

	opts_with_preview = {
		cwd = root_dir,
		prompt_title = title,
		shorten_path = true,
		layout_strategy = "vertical",
		layout_config = {
			width = 0.9,
			height = 0.9,
			preview_height = 0.7,
			mirror = true,
			anchor = "top",
			prompt_position = "top",
		},
	}

	opts_without_preview = vim.deepcopy(opts_with_preview)
	opts_without_preview.previewer = false

	require("telescope.builtin").find_files(opts_with_preview)
end

function actions.insert_link()
	local a = vim.api
	local win = a.nvim_get_current_win()
	local cursor = a.nvim_win_get_cursor(win)
	vim.ui.input({ prompt = "->" }, function(input)
		if input == nil then
			return
		end
		a.nvim_buf_set_text(
			0,
			cursor[1] - 1,
			cursor[2] + 1,
			cursor[1] - 1,
			cursor[2] + 1,
			{ "[" .. input .. "](notes/" .. input .. ".md)" }
		)
	end)
end

function actions.goto_link()
	local ts_utils = require("nvim-treesitter.ts_utils")
	local node = ts_utils.get_node_at_cursor()
	local link = node.parent(node)
	if link.type(node) == "inline_link" then
		local text = vim.treesitter.query.get_node_text(link.child(link), 0)
		local name = vim.split(text, "]")[1]
		local path = vim.split(text, "]")[2]
		name = name:sub(2, -1)
		path = path:sub(2, -2)
		if path then
			vim.api.nvim_command("e " .. path)
		end
	end
end

return actions
