return {
  "mfussenegger/nvim-lint",
  opts = function()
    require("lint").linters["markdownlint-cli2"].args = {
      "--config",
      vim.fn.expand("~/.markdownlint-cli2.yaml"),
    }
  end,
}
