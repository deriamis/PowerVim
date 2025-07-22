if not vim.g.powervim_explorer == "snacks" then
  return {
    "folke/snacks.nvim",
    keys = {
      { "<leader>fe", false },
      { "<leader>fE", false },
      { "<leader>e", false },
      { "<leader>E", false },
    },
  }
end

return {
  "folke/snacks.nvim",
  priority = 20,
  desc = "Snacks File Explorer",
  recommended = true,
  opts = { explorer = {} },
  keys = {
    {
      "<leader>fe",
      function()
        Snacks.explorer({ cwd = PowerVim.root() })
      end,
      desc = "Explorer Snacks (root dir)",
    },
    {
      "<leader>fE",
      function()
        Snacks.explorer()
      end,
      desc = "Explorer Snacks (cwd)",
    },
    { "<leader>e", "<leader>fe", desc = "Explorer Snacks (root dir)", remap = true },
    { "<leader>E", "<leader>fE", desc = "Explorer Snacks (cwd)", remap = true },
  },
}
