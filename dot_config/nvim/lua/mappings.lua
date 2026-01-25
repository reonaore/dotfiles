if not vim.g.vscode then
  require("nvchad.mappings")
end

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jj", "<ESC>")
map("n", "<S-h>", "^")
map("n", "<S-l>", "$")

if vim.g.vscode then
	local vscode = require("vscode")

	map("n", "<C-l>", "<C-w>l", { remap = true })
	map("n", "<C-h>", "<C-w>h", { remap = true })
	map("n", "<C-j>", "<C-w>j", { remap = true })
	map("n", "<C-k>", "<C-w>k", { remap = true })

	map("n", "<leader>e", function()
		vscode.action("workbench.view.explorer")
	end)
	map("n", "]g", function()
		vscode.action("editor.action.marker.nextInFiles")
	end)
	map("n", "[g", function()
		vscode.action("editor.action.marker.prevInFiles")
	end)
	map("n", "<leader>fm", function()
		vscode.action("editor.action.formatDocument")
	end)
	map("n", "<leader>fa", function()
		vscode.action("editor.action.showCommands")
	end)
	map("n", "mm", function()
		vscode.action("bookmarks.toggle")
	end)
	map("n", "ms", function()
		vscode.action("bookmarks.list")
	end)
	map("n", "gi", function()
		vscode.action("editor.action.goToImplementation")
	end)
	map("v", ">", function()
		vscode.action("editor.action.indentLines")
	end)
	map("v", "<", function()
		vscode.action("editor.action.outdentLines")
	end)
	map("v", "<leader>c", function()
		vscode.action("editor.action.commentLines")
	end)
else
	map("v", "<leader>c", "<leader>/", { remap = true })
end

if vim.g.vscode then
	vim.api.nvim_create_autocmd("InsertEnter", {
		callback = function()
			vim.defer_fn(function()
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Space><BS>", true, false, true), "n", false)
			end, 10)
		end,
	})
end

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
