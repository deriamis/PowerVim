vim.uv = vim.uv or vim.loop

local M = {}

---@param opts? PowerVimConfig
function M.setup(opts)
  require("powervim.config").setup(opts)
end

return M
