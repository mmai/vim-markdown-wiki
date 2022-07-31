local builtin = require "telescope.builtin"

local M = {}

local file_backlinks = function(opts)
  opts = opts or {}

  local title = vim.fn.expand('%:p')
  title = title:gsub("^(.-)([^/]+)$", "%2")

  local file_dir = vim.fn.expand('%:p:h')
  local root = vim.fn.systemlist("cd " ..  file_dir .. " && git rev-parse --show-toplevel ")[1]

  builtin.live_grep({
    cwd = root,
    prompt_title = "Files referencing `" .. title .. "` from " .. root,
    default_text = title .. "\\)",
  })
end

local friends_backlinks = function(opts)
  opts = opts or {}

  vim.cmd("normal t)yi)")
  local title = vim.fn.getreg('"0')
  title = title:gsub("^(.-)([^/]+)$", "%2")

  local file_dir = vim.fn.expand('%:p:h')
  local root = vim.fn.systemlist("cd " ..  file_dir .. " && git rev-parse --show-toplevel ")[1]

  builtin.live_grep({
    cwd = root,
    prompt_title = "Files referencing `" .. title .. "` from " .. root,
    default_text = title .. "\\)",
  })
end

M.friends_backlinks = friends_backlinks
M.file_backlinks = file_backlinks

return M
