--/lua/pluins/lua
return {
  -- Gruvbox colorscheme
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        inverse = true,
        contrast = "hard", -- Enhanced contrast for better readability
        palette_overrides = {},
        overrides = {
          -- Custom overrides for better UI integration
          SignColumn = { bg = "none" },
          CursorLineNr = { fg = "#fabd2f", bold = true },
          LineNr = { fg = "#665c54" },
          NormalFloat = { bg = "#1d2021" },
          FloatBorder = { fg = "#fe8019", bg = "#1d2021" },
          -- Telescope overrides
          TelescopeNormal = { bg = "#1d2021" },
          TelescopeBorder = { fg = "#fe8019", bg = "#1d2021" },
          TelescopePromptBorder = { fg = "#fabd2f", bg = "#1d2021" },
          TelescopeResultsBorder = { fg = "#83a598", bg = "#1d2021" },
          TelescopePreviewBorder = { fg = "#b8bb26", bg = "#1d2021" },
          -- Neo-tree overrides
          NeoTreeNormal = { bg = "#1d2021" },
          NeoTreeNormalNC = { bg = "#1d2021" },
          NeoTreeEndOfBuffer = { bg = "#1d2021" },
          -- Alpha overrides for dashboard
          AlphaHeader = { fg = "#fabd2f" },
          AlphaButtons = { fg = "#83a598" },
          AlphaShortcut = { fg = "#fe8019" },
          AlphaFooter = { fg = "#928374", italic = true },
        },
        dim_inactive = false,
        transparent_mode = false,
      })
      vim.cmd("colorscheme gruvbox")
    end,
  },

  -- Lualine - Beautiful statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "gruvbox",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
          disabled_filetypes = {
            statusline = { "alpha", "neo-tree" },
            winbar = {},
          },
        },
        sections = {
          lualine_a = { { "mode", fmt = function(str) return str:sub(1,1) end } },
          lualine_b = {
            "branch",
            { "diff", symbols = { added = " ", modified = " ", removed = " " } },
            { "diagnostics", symbols = { error = " ", warn = " ", info = " ", hint = " " } }
          },
          lualine_c = {
            { "filename", path = 1, symbols = { modified = " ", readonly = " ", unnamed = "[No Name]" } }
          },
          lualine_x = {
            { "encoding", show_bomb = false },
            { "fileformat", icons_enabled = true },
            { "filetype", colored = true, icon_only = false }
          },
          lualine_y = { { "progress", fmt = function(str) return str:gsub("%%", "%%%%") end } },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "neo-tree", "lazy", "mason", "oil", "trouble" },
      })
    end,
  },

  -- Bufferline - Beautiful buffer tabs
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          themable = true,
          separator_style = "slant",
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
          end,
          offsets = {
            {
              filetype = "neo-tree",
              text = " File Explorer",
              text_align = "center",
              separator = true,
            },
            {
              filetype = "oil",

              separator = true,
            },
          },
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          persist_buffer_sort = true,
          always_show_bufferline = true,
          hover = {
            enabled = true,
            delay = 200,
            reveal = { "close" },
          },
          custom_filter = function(buf_number, buf_numbers)
            -- Filter out by buffer type
            if vim.bo[buf_number].filetype ~= "qf" then
              return true
            end
          end,
        },
        highlights = {
          fill = { bg = "#1d2021" },
          background = { fg = "#928374", bg = "#1d2021" },
          buffer_visible = { fg = "#a89984", bg = "#1d2021" },
          buffer_selected = { fg = "#fbf1c7", bg = "#3c3836", bold = true, italic = false },
          tab = { fg = "#928374", bg = "#1d2021" },
          tab_selected = { fg = "#fbf1c7", bg = "#3c3836" },
          tab_close = { fg = "#fb4934", bg = "#1d2021" },
          close_button = { fg = "#928374", bg = "#1d2021" },
          close_button_visible = { fg = "#a89984", bg = "#1d2021" },
          close_button_selected = { fg = "#fb4934", bg = "#3c3836" },
          separator = { fg = "#1d2021", bg = "#1d2021" },
          separator_visible = { fg = "#1d2021", bg = "#1d2021" },
          separator_selected = { fg = "#1d2021", bg = "#3c3836" },
          modified = { fg = "#fabd2f", bg = "#1d2021" },
          modified_visible = { fg = "#fabd2f", bg = "#1d2021" },
          modified_selected = { fg = "#fabd2f", bg = "#3c3836" },
        },
      })
    end,
  },

  -- Indent blankline - Beautiful indentation guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      local highlight = {
        "GruvboxRed",
        "GruvboxYellow",
        "GruvboxBlue",
        "GruvboxOrange",
        "GruvboxGreen",
        "GruvboxAqua",
        "GruvboxPurple",
      }
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "GruvboxRed", { fg = "#fb4934" })
        vim.api.nvim_set_hl(0, "GruvboxYellow", { fg = "#fabd2f" })
        vim.api.nvim_set_hl(0, "GruvboxBlue", { fg = "#83a598" })
        vim.api.nvim_set_hl(0, "GruvboxOrange", { fg = "#fe8019" })
        vim.api.nvim_set_hl(0, "GruvboxGreen", { fg = "#b8bb26" })
        vim.api.nvim_set_hl(0, "GruvboxAqua", { fg = "#8ec07c" })
        vim.api.nvim_set_hl(0, "GruvboxPurple", { fg = "#d3869b" })
      end)

      require("ibl").setup({
        indent = {
          char = "▏",
          tab_char = "▏",
          highlight = highlight,
        },
        scope = {
          enabled = true,
          show_start = false,
          show_end = false,
          highlight = highlight,
        },
        exclude = {
          filetypes = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lazyterm",
            "oil",
          },
        },
      })
    end,
  },

  -- Notify - Beautiful notifications
  {
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup({
        background_colour = "#1d2021",
        fps = 30,
        icons = {
          DEBUG = "",
          ERROR = "",
          INFO = "",
          TRACE = "✎",
          WARN = "",
        },
        level = 2,
        minimum_width = 50,
        render = "wrapped-compact",
        stages = "fade_in_slide_out",
        timeout = 5000,
        top_down = true,
        max_height = function()
          return math.floor(vim.o.lines * 0.75)
        end,
        max_width = function()
          return math.floor(vim.o.columns * 0.75)
        end,
      })
      vim.notify = require("notify")
    end,
  },

  -- Noice - Enhanced UI
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        routes = {
          {
            filter = {
              event = "msg_show",
              any = {
                { find = "%d+L, %d+B" },
                { find = "; after #%d+" },
                { find = "; before #%d+" },
                { find = "%d fewer lines" },
                { find = "%d more lines" },
              },
            },
            opts = { skip = true },
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },
      })
    end,
  },

  -- Dressing - Better UI for vim.ui
  {
    "stevearc/dressing.nvim",
    config = function()
      require("dressing").setup({
        input = {
          enabled = true,
          default_prompt = "Input:",
          prompt_align = "left",
          insert_only = true,
          start_in_insert = true,
          border = "rounded",
          relative = "cursor",
          prefer_width = 40,
          width = nil,
          max_width = { 140, 0.9 },
          min_width = { 20, 0.2 },
          win_options = {
            winhighlight = "NormalFloat:GruvboxBg0,FloatBorder:GruvboxOrange",
            winblend = 0,
            wrap = false,
          },
        },
        select = {
          enabled = true,
          backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
          trim_prompt = true,
          telescope = require("telescope.themes").get_dropdown({
            previewer = false,
            borderchars = {
              { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
              prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
              results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
              preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            },
          }),
        },
      })
    end,
  },

  -- Illuminate - Highlight matching words
  {
    "RRethy/vim-illuminate", 
    config = function()
      require("illuminate").configure({
        providers = {
          "lsp",
          "treesitter",
          "regex",
        },
        delay = 100,
        filetypes_denylist = {
          "alpha",
          "neo-tree",
          "oil",
          "lazy",
          "mason",
          "help",
        },
        under_cursor = true,
        large_file_cutoff = 2000,
        large_file_overrides = nil,
        min_count_to_highlight = 1,
      })
      -- Custom highlight groups for gruvbox
      vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = "#3c3836" })
      vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = "#3c3836" }) 
      vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = "#3c3836" })
    end,
  },

  -- Colorizer - Show colors in code
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        "*",
        css = { rgb_fn = true },
        html = { names = false },
      })
    end,
  },
}
