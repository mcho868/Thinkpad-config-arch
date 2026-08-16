-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- install language servers
        "basedpyright",
        "jdtls",
        "lua-language-server",
        "ruff",
        "typescript-language-server",

        -- install formatters
        "prettier",
        "stylua",

        -- install debuggers
        "debugpy",
        "java-debug-adapter",
        "java-test",

        -- install any other package
        "tree-sitter-cli",
      },
    },
  },
}
