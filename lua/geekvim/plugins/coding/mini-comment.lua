return {
  {
    "echasnovski/mini.comment",
    priority = 20,
    event = "VeryLazy",
    opts = {
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    priority = 20,
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
  },
}
