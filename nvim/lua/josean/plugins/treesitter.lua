return {
  "nvim-treesitter/nvim-treesitter",
  -- The current main branch is a rewrite and must be loaded at startup.
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local parsers = {
      "json",
      "javascript",
      "typescript",
      "tsx",
      "yaml",
      "html",
      "css",
      "prisma",
      "markdown",
      "markdown_inline",
      "svelte",
      "graphql",
      "bash",
      "lua",
      "vim",
      "dockerfile",
      "gitignore",
      "query",
      "vimdoc",
      "c",
    }

    local treesitter = require("nvim-treesitter")
    treesitter.setup()
    treesitter.install(parsers)

    -- Highlighting and indentation are provided through Neovim's Tree-sitter API.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(event)
        local ok = pcall(vim.treesitter.start, event.buf)
        if ok then
          vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    require("nvim-ts-autotag").setup()
  end,
}
