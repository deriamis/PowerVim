return {

  -- Ensure GitUI tool is installed
  {
    "mason-org/mason.nvim",
    priority = 20,
    opts = { ensure_installed = { "gitui" } },
    keys = {
      {
        "<leader>gG",
        function()
          Snacks.terminal({ "gitui" })
        end,
        desc = "GitUi (cwd)",
      },
      {
        "<leader>gg",
        function()
          Snacks.terminal({ "gitui" }, { cwd = GeekVim.root.get() })
        end,
        desc = "GitUi (Root Dir)",
      },
    },
  },
}
