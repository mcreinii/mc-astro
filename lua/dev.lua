if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process.
-- This is mainly for developing plugins.

vim.notify("Developer lua is enabled.", vim.log.levels.INFO)
require("mc-todo").setup {
  initial_target_file = "TODO.md",
  fallback_file = "~/notes/todo.md",
}
vim.keymap.set("n", "<leader>mt", "<CMD>MTodo<CR>", { silent = true })
