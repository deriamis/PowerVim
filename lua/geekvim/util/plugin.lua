local Plugin = require("lazy.core.plugin")

---@class geekvim.util.plugin
local M = {}

---@type string[]
M.core_imports = {}
M.handle_defaults = true

M.lazy_file_events = { "BufReadPost", "BufNewFile", "BufWritePre" }

---@type table<string, string>
M.renames = {
  ["windwp/nvim-spectre"] = "nvim-pack/nvim-spectre",
  ["jose-elias-alvarez/null-ls.nvim"] = "nvimtools/none-ls.nvim",
  ["null-ls.nvim"] = "none-ls.nvim",
  ["romgrk/nvim-treesitter-context"] = "nvim-treesitter/nvim-treesitter-context",
  ["glepnir/dashboard-nvim"] = "nvimdev/dashboard-nvim",
  ["markdown.nvim"] = "render-markdown.nvim",
  ["williamboman/mason.nvim"] = "mason-org/mason.nvim",
  ["williamboman/mason-lspconfig.nvim"] = "mason-org/mason-lspconfig.nvim",
}

function M.save_core()
  if vim.v.vim_did_enter == 1 then
    return
  end
  M.core_imports = vim.deepcopy(require("lazy.core.config").spec.modules)
end

function M.setup()
  M.fix_renames()
  M.power_file()
end

function M.power_file()
  -- Add support for the PowerFile event
  local Event = require("lazy.core.handler.event")

  Event.mappings.PowerFile = { id = "PowerFile", event = M.lazy_file_events }
  Event.mappings["User PowerFile"] = Event.mappings.PowerFile
end

function M.fix_renames()
  Plugin.Spec.add = GeekVim.inject.args(Plugin.Spec.add, function(self, plugin)
    if type(plugin) == "table" then
      if M.renames[plugin[1]] then
        GeekVim.warn(
          ("Plugin `%s` was renamed to `%s`.\nPlease update your config for `%s`"):format(
            plugin[1],
            M.renames[plugin[1]],
            self.importing or "GeekVim"
          ),
          { title = "GeekVim" }
        )
        plugin[1] = M.renames[plugin[1]]
      end
    end
  end)
end

return M
