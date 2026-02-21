return
{
	{
		
		"olimorris/onedarkpro.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
	{
		"neovim/nvim-lspconfig"
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPre", "BufNewFile" },
		---@module "ibl"
		---@type ibl.config
		opts = {
			indent = {
				char = "╎",
			}
		}
	},
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		opts = {
			options = {
				component_separators = { left = '', right = ''},
				section_separators = { left = '', right = ''},
				globalstatus = true,
				theme = 'onedark'
			},
			sections = {
				lualine_a = {
					{
						'mode',
						fmt = function(str)
							return ' ' .. str
						end,
					}
				},
				lualine_b = {
					{
						'filename',
						file_status = true,
						newfile_status = false,
						path = 0,

						shorting_target = 40,
						symbols = {
							modified = '*',
							unnamed = '',
						}
					}
				},
				lualine_c = {
					{
						'lsp_status',
						icon = '',
						ignore_lsp = {},
					},
					{
						'diagnostics'
					}
				},
				lualine_x = {
					{
						"filetype"
					}
				}
			}
		},
	},
	{
		"chrisgrieser/nvim-origami",
		event = "VeryLazy",
		opts = {
			foldKeymaps = {
				setup = false,
			},
		},

		init = function()
			vim.opt.foldlevel = 99
			vim.opt.foldlevelstart = 99
		end,
	},
	{
		"mason-org/mason.nvim",
		opts = {}
	},
	{
		'windwp/nvim-autopairs',
		event = "InsertEnter",
		opts = {}
	},
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-path'
		},
		event = "InsertEnter",
		config = function()
			local cmp = require'cmp'
			local kind_icons =
			{
				Text = "",
				Method = "",
				Function = "",
				Constructor = "",
				Field = "",
				Variable = "",
				Class = "",
				Interface = "",
				Module = "",
				Property = "",
				Unit = "",
				Value = "",
				Enum = "",
				Keyword = "",
				Snippet = "",
				Color = "",
				File = "",
				Reference = "",
				Folder = "",
				EnumMember = "",
				Constant = "",
				Struct = "",
				Event = "",
				Operator = "",
				TypeParameter = ""
			}

			cmp.setup({
				window = {
					completion = {
						border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
						winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
					},
					documentation = {
						border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
					},
				},
				mapping = cmp.mapping.preset.insert({
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),

					["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),

					['<C-Space>'] = cmp.mapping.complete(),
					['<C-e>'] = cmp.mapping.abort(),
					['<Tab>'] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
					{ name = 'path' }
				}),
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						-- Truncate the completion text to 50 chars
						vim_item.kind = (kind_icons[vim_item.kind] or "") .. " " .. vim_item.kind
						local max_width = 50
						if #vim_item.abbr > max_width then
							vim_item.abbr = vim_item.abbr:sub(1, max_width) .. "…"
						end
						return vim_item
					end,
				},
			})
		end
	},
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"Jorenar/nvim-dap-disasm"
		},
		keys = {
			{ "<leader>db", "<cmd>DapToggleBreakpoint<CR>" },
			{ "<leader>dc", "<cmd>DapContinue<CR>" },
			{ "<leader>dp", "<cmd>DapPause<CR>" },
			{ "<leader>dt", "<cmd>DapTerminate<CR>" },
			{ "<leader>dv", "<cmd>DapStepOver<CR>" },
			{ "<leader>du", "<cmd>DapStepOut<CR>" },
			{ "<leader>di", "<cmd>DapStepInto<CR>" },
		},
		config = function()
			local dap, dapui, disasm = require "dap", require "dapui", require "dap-disasm"

			disasm.setup(
				{
					dapui_register = true,

					dapview_register = false,

					dapview = {
						keymap = "D",
						label = "Disassembly [D]",
						short_label = "󰒓 [D]",
					},

					winbar = {
						enabled = true,
						labels = {
							step_into = "Step Into",
							step_over = "Step Over",
							step_back = "Step Back",
						},
						order = {
							"step_into", "step_over", "step_back"
						}
					},

					sign = "DapStopped",

					ins_before_memref = 16,

					ins_after_memref = 16,

					columns = {
						"address",
						"instructionBytes",
						"instruction",
					},
				}
			)

			dapui.setup()

			vim.keymap.set("n", "<leader>ds", dapui.open);
			vim.keymap.set("n", "<leader>dq", dapui.close);

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			dap.adapters.codelldb = {
				type = 'server',
				port = "${port}",
				executable = {
					command = "codelldb.cmd",
					args = {"--port", "${port}"},

					detached = false,
				}
			}

			dap.adapters.cppdbg = {
				id = 'cppdbg',
				type = 'executable',
				command = 'OpenDebugAD7.cmd',
				options = {
					detached = false
				}
			}

			dap.configurations.cpp = {
				{
					name = "Launch file (codelldb)",
					type = "codelldb",
					request = "launch",
					program = function()
						return vim.fn.input('Path to executable: ', '', 'file')
					end,
					cwd = '${workspaceFolder}',
					stopOnEntry = false
				},
				{
					name = "Launch file (cppdbg)",
					type = "cppdbg",
					request = "launch",
					program = function()
						return vim.fn.input('Path to executable: ', '', 'file')
					end,
					cwd = '${workspaceFolder}',
					stopAtEntry = false,
				},
				{
					name = 'Attach to gdbserver :1234',
					type = 'cppdbg',
					request = 'launch',
					MIMode = 'gdb',
					miDebuggerServerAddress = 'localhost:1234',
					miDebuggerPath = 'gdb',
					cwd = '${workspaceFolder}',
					program = function()
						return vim.fn.input('Path to executable: ', '', 'file')
					end,
				},
			}

			dap.configurations.c = dap.configurations.cpp
			dap.configurations.asm = dap.configurations.cpp
			dap.configurations.hlsl = dap.configurations.cpp

			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped", { text = "❭", texthl = "DapStopped", linehl = "", numhl = "" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "◉", texthl = "DapBreakpointRejected", linehl = "", numhl = "" })
		end,
	},
	{
		'stevearc/oil.nvim',
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {},
		dependencies = { "nvim-tree/nvim-web-devicons" },
		lazy = false,
	},
	{
		"nvim-tree/nvim-tree.lua",
		keys = {
			{"<C-n>", "<cmd>NvimTreeToggle<CR>"}
		},
		opts = {
			actions = {
				open_file = {
					quit_on_open = true
				},
			},
			renderer = {
				root_folder_label = false
			}
		}
	},
	{
		"nvim-treesitter/nvim-treesitter",
		branch = 'master',
		event = { "BufReadPre", "BufNewFile" },
		config = function ()
			require	"nvim-treesitter.configs".setup {
				highlight = {
					enable = true,
				}
			}
		end
	},
	{
		'nvim-telescope/telescope.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },
		lazy = true,
		keys = {
			{'<leader>fpf', "<cmd>Telescope find_files<CR>"},
			{'<leader>fpg', "<cmd>Telescope live_grep<CR>"},
			{'<leader>fgb', "<cmd>Telescope git_branches<CR>"},
			{'<leader>fgf', "<cmd>Telescope git_files<CR>"},
			{'<leader>fgs', "<cmd>Telescope git_status<CR>"},
			{'<leader>fgpc', "<cmd>Telescope git_commits<CR>"},
			{'<leader>fgbc', "<cmd>Telescope git_bcommits<CR>"},
			{'<leader>fd', "<cmd>Telescope diagnostics<CR>"},
			{'<leader>fb', "<cmd>Telescope buffers<CR>"},
			{'<leader>fh', "<cmd>Telescope help_tags<CR>"},
			{'<leader>fk', "<cmd>Telescope keymaps<CR>"},
			{'<leader>ft', "<cmd>Telescope colorscheme<CR>"}
		},
		opts = {}
	},
	{
		"ThePrimeagen/harpoon",
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function ()
			vim.keymap.set("n", "<leader>ha", function () require("harpoon.mark").add_file() end)
			vim.keymap.set("n", "<leader>he", function () require("harpoon.ui").toggle_quick_menu() end)
			vim.keymap.set("n", "<leader>hn", function () require("harpoon.ui").nav_next() end)
			vim.keymap.set("n", "<leader>hp", function () require("harpoon.ui").nav_prev() end)
			vim.keymap.set("n", "<M-1>", function () require("harpoon.ui").nav_file(1) end)
			vim.keymap.set("n", "<M-2>", function () require("harpoon.ui").nav_file(2) end)
			vim.keymap.set("n", "<M-3>", function () require("harpoon.ui").nav_file(3) end)
			vim.keymap.set("n", "<M-4>", function () require("harpoon.ui").nav_file(4) end)
		end
	},
	{
		"folke/trouble.nvim",
		lazy = true,
		opts = {},
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
			},
		},
	},
	{
		"tpope/vim-surround"
	},
	{
		"folke/zen-mode.nvim",
		lazy = true,
		keys = {
			{ "<F4>", function ()
				require("zen-mode").toggle({
					window = {
						width = .80
					}
				}) end
			}
		},
		opts = {}
	},
	{
		'akinsho/toggleterm.nvim',
		lazy = false,
		version = "*",
		opts = {}
	}
}
