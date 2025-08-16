_G.GeekVim = require("geekvim.util")

---@class GeekVimConfig: GeekVimOptions
local M = {}

M.version = "0.1.0"
GeekVim.config = M

---@class GeekVimOptions
local defaults = {
  ---@type string|fun()
  colorscheme = function()
    require("tokyonight").load()
  end,
  -- load the default settings
  defaults = {
    autocmds = true,
    keymaps = true,
  },
  icons = {
    misc = {
      dots = "󰇘",
    },
    ft = {
      octo = "",
    },
    dap = {
      Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint = " ",
      BreakpointCondition = " ",
      BreakpointRejected = { " ", "DiagnosticError" },
      LogPoint = ".>",
    },
    diagnostics = {
      Error = " ",
      Warn = " ",
      Hint = " ",
      Info = " ",
    },
    git = {
      added = " ",
      modified = " ",
      removed = " ",
    },
    kinds = {
      Array = " ",
      Boolean = "󰨙 ",
      Class = " ",
      Codeium = "󰘦 ",
      Color = " ",
      Control = " ",
      Collapsed = " ",
      Constant = "󰏿 ",
      Constructor = " ",
      Copilot = " ",
      Enum = " ",
      EnumMember = " ",
      Event = " ",
      Field = " ",
      File = " ",
      Folder = " ",
      Function = "󰊕 ",
      Interface = " ",
      Key = " ",
      Keyword = " ",
      Method = "󰊕 ",
      Module = " ",
      Namespace = "󰦮 ",
      Null = " ",
      Number = "󰎠 ",
      Object = " ",
      Operator = " ",
      Package = " ",
      Property = " ",
      Reference = " ",
      Snippet = "󱄽 ",
      String = " ",
      Struct = "󰆼 ",
      Supermaven = " ",
      TabNine = "󰏚 ",
      Text = " ",
      TypeParameter = " ",
      Unit = " ",
      Value = " ",
      Variable = "󰀫 ",
    },
  },
  ---@type table<string, string[]|boolean>?
  kind_filter = {
    default = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      "Package",
      "Property",
      "Struct",
      "Trait",
    },
    markdown = false,
    help = false,
    lua = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      "Property",
      "Struct",
      "Trait",
    },
  },
}

---@type GeekVimOptions
local options
local clipboard

---@param opts? GeekVimOptions
function M.setup(opts)
  options = vim.tbl_deep_extend("force", defaults, opts or {}) or {}

  -- autocmds can be loaded lazily when not opening a file
  local autocmds = vim.fn.argc(-1) == 0
  if not autocmds then
    M.load("autocmds")
  end

  local group = vim.api.nvim_create_augroup("GeekVim", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    callback = function()
      if autocmds then
        M.load("autocmds")
      end
      M.load("keymaps")
      if clipboard ~= nil then
        vim.opt.clipboard = clipboard
      end

      GeekVim.format.setup()
      GeekVim.root.setup()

      vim.api.nvim_create_user_command("PowerHealth", function()
        vim.cmd([[Lazy! load all]])
        vim.cmd([[checkhealth]])
      end, { desc = "Load all plugins and run :checkhealth" })

      local health = require("lazy.health")
      vim.list_extend(health.valid, {
        "recommended",
        "desc",
        "vscode",
      })

      if vim.g.geekvim_check_order == false then
        return
      end

      -- Check lazy.nvim import order
      local imports = require("lazy.core.config").spec.modules
      local function find(pat, last)
        for i = last and #imports or 1, last and 1 or #imports, last and -1 or 1 do
          if imports[i]:find(pat) then
            return i
          end
        end
      end
      local geekvim_plugins = find("^geekvim%.plugins$")
      if geekvim_plugins ~= 1 then
        local msg = {
          "The order of your `power.nvim` imports is incorrect:",
          "- `geekvim.plugins` should be first",
          "- followed by your own `plugins`",
          "",
          "If you think you know what you're doing, you can disable this check with:",
          "```lua",
          "vim.g.geekvim_check_order = false",
          "```",
        }
        vim.notify(table.concat(msg, "\n"), "warn", { title = "GeekVim" })
      end
    end,
  })

  GeekVim.track("colorscheme")
  GeekVim.try(function()
    if type(M.colorscheme) == "function" then
      M.colorscheme()
    else
      vim.cmd.colorscheme(M.colorscheme)
    end
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg)
      GeekVim.error(msg)
      vim.cmd.colorscheme("habamax")
    end,
  })
  GeekVim.track()
end

---@param buf? number
---@return string[]?
function M.get_kind_filter(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local ft = vim.bo[buf].filetype
  if M.kind_filter == false then
    return
  end
  if M.kind_filter[ft] == false then
    return
  end
  if type(M.kind_filter[ft]) == "table" then
    return M.kind_filter[ft]
  end
  ---@diagnostic disable-next-line: return-type-mismatch
  return type(M.kind_filter) == "table" and type(M.kind_filter.default) == "table" and M.kind_filter.default or nil
end

---@param buf? number
---@return string[]?
function M.get_kind_filter(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local ft = vim.bo[buf].filetype
  if M.kind_filter == false then
    return
  end
  if M.kind_filter[ft] == false then
    return
  end
  if type(M.kind_filter[ft]) == "table" then
    return M.kind_filter[ft]
  end
  ---@diagnostic disable-next-line: return-type-mismatch
  return type(M.kind_filter) == "table" and type(M.kind_filter.default) == "table" and M.kind_filter.default or nil
end

---@param name "autocmds" | "options" | "keymaps"
function M.load(name)
  local function _load(mod)
    if require("lazy.core.cache").find(mod)[1] then
      GeekVim.try(function()
        require(mod)
      end, { msg = "Failed loading " .. mod })
    end
  end
  local pattern = "GeekVim" .. name:sub(1, 1):upper() .. name:sub(2)
  -- always load geekvim, then user file
  if M.defaults[name] or name == "options" then
    _load("geekvim.config." .. name)
    vim.api.nvim_exec_autocmds("User", { pattern = pattern .. "Defaults", modeline = false })
  end
  _load("config." .. name)
  if vim.bo.filetype == "lazy" then
    -- HACK: GeekVim may have overwritten options of the Lazy ui, so reset this here
    vim.cmd([[do VimResized]])
  end
  vim.api.nvim_exec_autocmds("User", { pattern = pattern, modeline = false })
end

M.did_init = false
function M.init()
  if M.did_init then
    return
  end
  M.did_init = true
  local plugin = require("lazy.core.config").spec.plugins.GeekVim
  if plugin then
    vim.opt.rtp:append(plugin.dir)
  end

  package.preload["geekvim.plugins.lsp.format"] = GeekVim.format

  -- delay notifications till vim.notify was replaced or after 500ms
  GeekVim.lazy_notify()

  -- load options here, before lazy init while sourcing plugin modules
  -- this is needed to make sure options will be correctly applied
  -- after installing missing plugins
  M.load("options")
  -- defer built-in clipboard handling: "xsel" and "pbcopy" can be slow
  clipboard = vim.opt.clipboard
  vim.opt.clipboard = ""

  if vim.g.deprecation_warnings == false then
    vim.deprecate = function() end
  end

  GeekVim.plugin.setup()
end

setmetatable(M, {
  __index = function(_, key)
    if options == nil then
      return vim.deepcopy(defaults)[key]
    end
    ---@cast options GeekVimConfig
    return options[key]
  end,
})

return M
