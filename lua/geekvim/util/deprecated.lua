local M = {}

M.moved = {}

---@param name string
---@param mod table
function M.decorate(name, mod)
  if not M.moved[name] then
    return mod
  end
  setmetatable(mod, {
    __call = function(_, ...)
      local to = M.moved[name].__call[1]
      GeekVim.deprecate("GeekVim." .. name, to)
      local ret = vim.tbl_get(_G, unpack(vim.split(to, ".", { plain = true })))
      return ret(...)
    end,
    __index = function(_, k)
      if M.moved[name][k] then
        local to = M.moved[name][k][1]
        GeekVim.deprecate("GeekVim." .. name .. "." .. k, to)
        if M.moved[name][k].fn then
          return M.moved[name][k].fn
        end
        local ret = vim.tbl_get(_G, unpack(vim.split(to, ".", { plain = true })))
        return ret
      end
      return nil
    end,
  })
end

return M
