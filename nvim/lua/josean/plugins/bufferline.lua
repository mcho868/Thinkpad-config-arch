return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = {
    options = {
      mode = "tabs",
      separator_style = "slant",
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)

    -- Bufferline's tabs mode uses :tabclose for its close actions, which
    -- raises E784 when the current tab is the only tab page.
    local options = require("bufferline.config").get().options
    local function close_tab_safely(tab_handle)
      if #vim.api.nvim_list_tabpages() <= 1 then
        vim.notify("Cannot close the last tab page", vim.log.levels.WARN, { title = "Bufferline" })
        return
      end

      local ok, tab_number = pcall(vim.api.nvim_tabpage_get_number, tab_handle)
      if ok then
        vim.cmd("tabclose " .. tab_number)
      end
    end

    options.close_command = close_tab_safely
    options.right_mouse_command = close_tab_safely
  end,
}
