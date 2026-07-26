return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {},
      },
    },
  },
  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      user_default_options = {
        tailwind = true,
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
    },
    opts = function(_, opts)
      local format_kinds = opts.formatting and opts.formatting.format or function(_, item) return item end

      opts.formatting = opts.formatting or {}
      opts.formatting.format = function(entry, item)
        item = format_kinds(entry, item)  -- preserve original icons/kinds
        return require("tailwindcss-colorizer-cmp").formatter(entry, item)
      end
    end,
  },
}
