vim.api.nvim_buf_set_keymap(
  0,
  "n",
  "<CR>",
  "<cmd>lua require('kulala').run()<cr>",
  { noremap = true, silent = true, desc = "Execute the request" }
)

vim.api.nvim_buf_set_keymap(
  0,
  "n",
  "<leader>i",
  "<cmd>lua require('kulala').inspect()<cr>",
  { noremap = true, silent = true, desc = "Inspect the current request" }
)

vim.api.nvim_buf_set_keymap(
  0,
  "n",
  "<leader>co",
  "<cmd>lua require('kulala').copy()<cr>",
  { noremap = true, silent = true, desc = "Copy the current request as a curl command" }
)
