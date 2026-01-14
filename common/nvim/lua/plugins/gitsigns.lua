return {
  "lewis6991/gitsigns.nvim",
  event = "BufReadPost",
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "―" },
      changedelete = { text = "~" },
    },
    on_attach = function(bufnr)
      vim.keymap.set("n", "<leader>gb", function()
        require("gitsigns").toggle_current_line_blame()
      end, { desc = "Toggle Git Blame", buffer = bufnr })
    end,
    current_line_blame = true, -- Enable blame on current line by default
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
      delay = 100,
      ignore_whitespace = false,
    },
    -- Other options can be added here if needed
  },
}