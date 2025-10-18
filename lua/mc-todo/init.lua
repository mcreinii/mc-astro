local M = {}

local function expand_path(path)
  if path:sub(1, 1) == "~" then return os.getenv "HOME" .. path:sub(2) end
  return path
end

local function window_config()
  local width = math.min(math.floor(vim.o.columns * 0.6), 64)
  local heigth = math.floor(vim.o.lines * 0.8)

  return {
    relative = "editor",
    height = heigth,
    width = width,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - heigth) / 2,
    border = "single",
  }
end

local function open_floating_markdown(target_file, opts)
  local expanded_path = expand_path(target_file)
  local fallback_path = expand_path(opts.fallback_file)

  if vim.fn.filereadable(expanded_path) == 0 then
    vim.notify("No " .. target_file .. " found.", vim.log.levels.INFO)

    if vim.fn.filereadable(fallback_path) == 0 then
      vim.notify("There's no fallback file found.", vim.log.levels.WARN)
      return
    end

    expanded_path = fallback_path
  end

  local buf = vim.fn.bufnr(expanded_path, true)

  if buf == -1 then
    buf = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_buf_set_name(buf, expanded_path)
  end

  vim.bo[buf].swapfile = false

  vim.api.nvim_open_win(buf, true, window_config())

  vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
    silent = true,
    noremap = true,
    callback = function()
      if vim.api.nvim_get_option_value("modified", { buf = buf }) then
        vim.notify "Save changes before closing."
      else
        vim.api.nvim_win_close(0, false)
      end
    end,
  })

  vim.api.nvim_buf_set_keymap(buf, "n", "Q", "", {
    silent = true,
    noremap = true,
    callback = function() vim.api.nvim_win_close(0, true) end,
  })
end

local function setup_commands(opts)
  local initial_target_file = opts.initial_target_file or "todo.md"
  vim.api.nvim_create_user_command(
    "MTodo",
    function() open_floating_markdown(initial_target_file, opts) end,
    { desc = "Opens a floating windows of a markdown todo list." }
  )
end

M.setup = function(opts) setup_commands(opts) end

return M
