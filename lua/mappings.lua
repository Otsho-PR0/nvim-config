vim.keymap.set('v', "J", ":m '>+1<CR>gv=gv")
vim.keymap.set('v', "K", ":m '<-2<CR>gv=gv")

vim.keymap.set('x', '<leader>p', "\"_dP")

vim.keymap.set('n', "<leader>y", "\"+y")
vim.keymap.set('v', "<leader>y", "\"+y")
vim.keymap.set('n', "<leader>Y", "\"+Y")

vim.keymap.set('n', "<leader>d", "\"_d")
vim.keymap.set('v', "<leader>d", "\"_d")

vim.keymap.set('i', "<C-c>", "<Esc>")

vim.keymap.set("n", "<Esc>", "<cmd>noh<CR>")

vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")

vim.keymap.set("t", "<C-x>", "<C-\\><C-N>")
vim.keymap.set({"n", "t"}, "<M-t>", "<cmd>ToggleTerm direction=float<CR>")

vim.keymap.set("n", "-", function () vim.cmd "Oil" end);

vim.keymap.set("n", "<leader>r", function ()
	local cmd = "!" .. vim.fn.input("Run: ", "", "file")
	vim.cmd(cmd)
end)
