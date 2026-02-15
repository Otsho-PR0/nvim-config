local servers =
{
	"lua_ls",
	"clangd",
	"chsarp-ls",
	"gopls",
	"neocmake",
	"slangd",
	"glsl_analyzer",
	"pyright",
	"ts_ls",
	"jsonls",
	"html",
	"emmet_ls",
	"cssls"
}

local function on_attach(_, bufnr)
	local function opts(desc)
		return { buffer = bufnr, remap=false, desc = "LSP " .. desc }
	end

	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
	vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
	vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")
	vim.keymap.set("n", "<leader>wl", function()
	  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, opts "List workspace folders")
	vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts "Go to type definition")
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts "Code action")
	vim.keymap.set("n", "grr", vim.lsp.buf.references, opts "References")
	vim.keymap.set("n", "grn", vim.lsp.buf.rename, opts "Rename")
	vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts "Signature help")
	vim.keymap.set("n", "[d", function ()
		vim.diagnostic.jump({count=-1, float=true})
	end, opts "Go to next diagnostic")
	vim.keymap.set("n", "]d", function ()
		vim.diagnostic.jump({count=1, float=true})
	end, opts "Go to prev diagnostic")
end

vim.lsp.config("*",
{
	on_attach = on_attach,
	capabilities = vim.lsp.protocol.make_client_capabilities()
})

vim.lsp.config("lua_ls",
{
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		".luarc.json",
		".luarc.jsonc",
		".luacheckrc",
		".stylua.toml",
		"stylua.toml",
		"selene.toml",
		"selene.yml",
		".git",
	},
	settings = {
		Lua = {
			workspace = {
				checkThirdParty = false,
				library = {
					vim.fn.expand "$VIMRUNTIME/lua",
					vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
					"${3rd}/luv/library",
					"${3rd}/love2d/library",
					vim.loop.cwd()
				}
			}
		}
	},
	on_attach = on_attach
})

vim.lsp.config("clangd",
{
	cmd = { "clangd", "--header-insertion=never", "--fallback-style=Microsoft" }, --, "--background-index=false" },
	filetypes = { "c", "cpp" },
	root_markers = {
		".clangd",
		".clang-tidy",
		".clang-format",
		"compile_commands.json",
		"compile_flags.txt",
		"configure.ac",
		".git",
	},
	capabilities = {
		textDocument = {
			completion = {
				editsNearCursor = true,
			},
		},
		offsetEncoding = { "utf-8", "utf-16" },
	},
	---@param client vim.lsp.Client
	---@param init_result ClangdInitializeResult
	on_init = function(client, init_result)
		if init_result.offsetEncoding then
			client.offset_encoding = init_result.offsetEncoding
		end
	end,
	on_attach = function(_, bufnr)
		local function switch_source_header(bufnr)
			local method_name = "textDocument/switchSourceHeader"
			local client = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
			if not client then
				return vim.notify(("method %s is not supported by any servers active on the current buffer"):format(method_name))
			end
			local params = vim.lsp.util.make_text_document_params(bufnr)
			client.request(method_name, params, function(err, result)
				if err then
					error(tostring(err))
				end
				if not result then
					vim.notify("corresponding file cannot be determined")
					return
				end
				vim.cmd.edit(vim.uri_to_fname(result))
			end, bufnr)
		end

		local function symbol_info()
			local bufnr = vim.api.nvim_get_current_buf()
			local clangd_client = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
			if not clangd_client or not clangd_client.supports_method "textDocument/symbolInfo" then
				return vim.notify("Clangd client not found", vim.log.levels.ERROR)
			end
			local win = vim.api.nvim_get_current_win()
			local params = vim.lsp.util.make_position_params(win, clangd_client.offset_encoding)
			clangd_client.request("textDocument/symbolInfo", params, function(err, res)
				if err or #res == 0 then
					-- Clangd always returns an error, there is not reason to parse it
					return
				end
				local container = string.format("container: %s", res[1].containerName) ---@type string
				local name = string.format("name: %s", res[1].name) ---@type string
				vim.lsp.util.open_floating_preview({ name, container }, "", {
					height = 2,
					width = math.max(string.len(name), string.len(container)),
					focusable = false,
					focus = false,
					border = "single",
					title = "Symbol Info",
				})
			end, bufnr)
		end

		vim.api.nvim_buf_create_user_command(bufnr, "LspClangdSwitchSourceHeader", function()
			switch_source_header(bufnr)
		end, { desc = "Switch between source/header" })

		vim.api.nvim_buf_create_user_command(bufnr, "LspClangdShowSymbolInfo", function()
			symbol_info()
		end, { desc = "Show symbol info" })

		vim.keymap.set("n", "<leader>sh", "<cmd>LspClangdSwitchSourceHeader<CR>")

		vim.keymap.set("n", "<leader>si", "<cmd>LspClangdShowSymbolInfo<CR>")

		on_attach()
	end,
})

vim.lsp.config("neocmake",
{
	filetypes = { "cmake" },
	init_options = { format = { enable = true }, lint = { enable = true } },
	on_attach = on_attach
})

vim.lsp.enable(servers)

local x = vim.diagnostic.severity

vim.diagnostic.config {
	virtual_text = false,
	signs = { text = { [x.ERROR] = "󰅙", [x.WARN] = "", [x.INFO] = "󰋼", [x.HINT] = "󰌵" } },
	underline = false,
	float = { border = "single" },
}
