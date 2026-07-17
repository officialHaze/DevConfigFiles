-- Format on save and linters
return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
		"jay-babu/mason-null-ls.nvim", -- Updated to the active community fork
	},
	config = function()
		local null_ls = require("null-ls")
		local formatting = null_ls.builtins.formatting -- Setup formatters
		local diagnostics = null_ls.builtins.diagnostics -- Setup linters

		-- List of formatters & linters for Mason to install automatically
		require("mason-null-ls").setup({
			ensure_installed = {
				"checkmake",
				"prettier", -- TS/JS/JSON/YAML formatter
				"eslint_d", -- TS/JS linter
				"shfmt", -- Shell formatter
				"gofumpt", -- Go formatter
				"goimports", -- Go import organizer
				"golangci_lint", -- Go linter
				"stylua", -- Lua formatter
				-- 'terraform',     -- Terraform formatter (installs terraform binary)
				-- 'ruff',          -- Python formatter/linter
			},
			automatic_installation = true,
		})

		local sources = {
			-- Diagnostics (Linters)
			diagnostics.checkmake,
			diagnostics.golangci_lint,

			-- If you want JS/TS linting, uncomment this line:
			-- require("none-ls.diagnostics.eslint_d"),

			-- Formatters
			formatting.prettier.with({ filetypes = { "html", "json", "yaml", "markdown" } }),
			formatting.stylua,
			formatting.shfmt.with({ args = { "-i", "4" } }),
			formatting.gofumpt,
			formatting.goimports,
			formatting.terraform_fmt,

			-- Python (Ruff) via none-ls-extras
			-- require('none-ls.formatting.ruff').with { extra_args = { '--extend-select', 'I' } },
			-- require 'none-ls.formatting.ruff_format',
		}

		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

		null_ls.setup({
			sources = sources,
			on_attach = function(client, bufnr)
				if client:supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							-- Added timeout_ms to prevent Neovim from freezing if a formatter hangs
							vim.lsp.buf.format({ async = false, timeout_ms = 2000 })
						end,
					})
				end
			end,
		})
	end,
}
