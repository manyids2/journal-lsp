require("journal-lsp.globals")

local actions = {}

function actions.find_files()
  local opts_with_preview, opts_without_preview

  opts_with_preview = {
    prompt_title = "~ all files ~",
    shorten_path = false,

    layout_strategy = "flex",
    layout_config = {
      width = 0.9,
      height = 0.8,

      horizontal = {
        width = { padding = 0.15 },
      },
      vertical = {
        preview_height = 0.75,
      },
    },
  }

  opts_without_preview = vim.deepcopy(opts_with_preview)
  opts_without_preview.previewer = false

  require("telescope.builtin").find_files(opts_with_preview)
end

function actions.insert_link()
  -- get context
  local a = vim.api
  local win = a.nvim_get_current_win()
  local cursor = a.nvim_win_get_cursor(win)
  a.nvim_buf_set_text(0, cursor[1] - 1, cursor[2] + 1, cursor[1] - 1, cursor[2] + 1, {'[]()'})
end

return actions
