-- measure startuptime
return {
  "dstein64/vim-startuptime",
  priority = 20,
  cmd = "StartupTime",
  config = function()
    vim.g.startuptime_tries = 10
  end,
}
