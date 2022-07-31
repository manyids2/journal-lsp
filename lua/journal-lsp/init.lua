local M = {}

M.name = "journal-lsp"
M.filetypes = {"markdown", "telekasten"}
M.enabled = false

M.setup = function ()
  require("journal-lsp.globals")

  -- 1. is it md file?
  if not CE(M.filetypes, vim.bo.filetype) then
    return
  end

  -- 2. is it 'journal' dir?
  local root_dir = (vim.fs.dirname(vim.fs.find({
      'index.md', 'README.md'
    }, {upward = true})[1]))
  if (root_dir) then
    M.root_dir = root_dir
    M.enabled = true
  else
    require("index.md not found.")
    return
  end

  -- 3. init
  vim.notify('journal-lsp started')
  M.actions = require("journal-lsp.actions")
end

return M
