return {
	"okuuva/auto-save.nvim",
	version = "^1.0.0",
	cmd = "ASToggle",
	event = { "InsertLeave", "TextChanged" },
	debounce_delay = 10, -- delay after which a pending save is executedF
	opts = {
		condition = function(buf)
			local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
			if buftype ~= "" then
				return false
			end
			return true
		end,
	},
}
