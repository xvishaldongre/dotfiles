return {
	"cenk1cenk2/schema-companion.nvim",
	ft = "yaml", -- only load on YAML files
	dependencies = { "nvim-lua/plenary.nvim" },
    
	config = function()
		require("schema-companion").setup({
			enable_telescope = false,
			matchers = {
				require("schema-companion.matchers.kubernetes").setup({ version = "master" }),
			},
		})
		require("lspconfig").yamlls.setup(require("schema-companion").setup_client({
			settings = {
				yaml = {
					validate = true,
					format = { enable = true },
					schemaStore = { enable = false, url = "" },
				},
			},
		}))
	end,
}
