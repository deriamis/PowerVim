vim.uv = vim.uv or vim.loop

vim.env.XDG_USER_DIR = vim.env.XDG_USER_DIR .. vim.env.HOME .. "/.local"
vim.env.XDG_DATA_HOME = vim.env.XDG_DATA_HOME .. vim.env.XDG_USER_DIR .. "/share"
vim.env.XDG_STATE_HOME = vim.env.XDG_STATE_HOME .. vim.env.XDG_USER_DIR .. "/state"
vim.env.XDG_CONFIG_HOME = vim.env.XDG_CONFIG_HOME .. vim.env.HOME .. "/.config"
vim.env.XDG_CACHE_HOME = vim.env.XDG_CACHE_HOME .. vim.env.HOME .. "/.cache"

local mise_shims_path = vim.env.XDG_DATA_HOME .. "/mise/shims"
if vim.fn.isdirectory(mise_shims_path) then
  -- Prepend mise shims to PATH
  vim.env.PATH = mise_shims_path .. ":" .. vim.env.PATH
end

local M = {}

---@param opts? GeekVimConfig
function M.setup(opts)
  require("geekvim.config").setup(opts)
end

return M
