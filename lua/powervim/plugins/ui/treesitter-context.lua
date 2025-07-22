-- Show context of the current function
return {
  "nvim-treesitter/nvim-treesitter-context",
  priority = 20,
  event = "PowerFile",
  opts = function()
    local tsc = require("treesitter-context")
    Snacks.toggle({
      name = "Treesitter Context",
      get = tsc.enabled,
      set = function(state)
        if state then
          tsc.enable()
        else
          tsc.disable()
        end
      end,
    }):map("<leader>ut")
    return { mode = "cursor", max_lines = 3 }
  end,
}
