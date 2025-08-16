---@class geekvim.util.pick
---@overload fun(command:string, opts?:geekvim.util.pick.Opts): fun()
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.wrap(...)
  end,
})

---@class geekvim.util.pick.Opts: table<string, any>
---@field root? boolean
---@field cwd? string
---@field buf? number
---@field show_untracked? boolean

---@class PowerPicker
---@field name string
---@field open fun(command:string, opts?:geekvim.util.pick.Opts)
---@field commands table<string, string>

---@type PowerPicker?
M.picker = nil

---@param picker PowerPicker
function M.register(picker)
  if M.picker and M.picker.name ~= picker.name then
    GeekVim.warn(
      "`GeekVim.pick`: picker already set to `" .. M.picker.name .. "`,\nignoring new picker `" .. picker.name .. "`"
    )
    return false
  end
  M.picker = picker
  return true
end

---@param command? string
---@param opts? geekvim.util.pick.Opts
function M.open(command, opts)
  if not M.picker then
    return GeekVim.error("GeekVim.pick: picker not set")
  end

  command = command ~= "auto" and command or "files"
  opts = opts or {}

  opts = vim.deepcopy(opts)

  if type(opts.cwd) == "boolean" then
    GeekVim.warn("GeekVim.pick: opts.cwd should be a string or nil")
    opts.cwd = nil
  end

  if not opts.cwd and opts.root ~= false then
    opts.cwd = GeekVim.root({ buf = opts.buf })
  end

  command = M.picker.commands[command] or command
  M.picker.open(command, opts)
end

---@param command? string
---@param opts? geekvim.util.pick.Opts
function M.wrap(command, opts)
  opts = opts or {}
  return function()
    GeekVim.pick.open(command, vim.deepcopy(opts))
  end
end

function M.config_files()
  return M.wrap("files", { cwd = vim.fn.stdpath("config") })
end

return M
