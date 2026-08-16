-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Raycast-style quick note: persist edits whenever the popup loses focus or
-- insert mode is left. Other Markdown files retain normal save behavior.
local quick_note = vim.fn.expand "~/.local/share/notes/quick-note.md"
vim.api.nvim_create_autocmd({ "InsertLeave", "FocusLost", "BufLeave" }, {
  pattern = quick_note,
  callback = function(args)
    if vim.bo[args.buf].modified and vim.bo[args.buf].modifiable then
      vim.api.nvim_buf_call(args.buf, function() vim.cmd "silent update" end)
    end
  end,
  desc = "Autosave the Raycast-style quick note",
})
