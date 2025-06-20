return {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    config = function()
        -- Define Gruvbox colors
        local colors = {
            bg = "#282828",
            fg = "#ebdbb2",
            red = "#fb4934",
            green = "#b8bb26",
            yellow = "#fabd2f",
            blue = "#83a598",
            purple = "#d3869b",
            aqua = "#8ec07c",
            orange = "#fe8019",
            gray = "#928374",
            dark_gray = "#1d2021",
            light_gray = "#a89984",
        }

        -- Set up highlight groups
        vim.api.nvim_set_hl(0, "DashboardHeader", { fg = colors.orange, bold = true })
        vim.api.nvim_set_hl(0, "DashboardCenter", { fg = colors.blue, bold = true })
        vim.api.nvim_set_hl(0, "DashboardShortCut", { fg = colors.red, bold = true })
        vim.api.nvim_set_hl(0, "DashboardFooter", { fg = colors.purple, italic = true })
        vim.api.nvim_set_hl(0, "DashboardIcon", { fg = colors.yellow })
        vim.api.nvim_set_hl(0, "DashboardDesc", { fg = colors.green })
        vim.api.nvim_set_hl(0, "DashboardKey", { fg = colors.red, bold = true })

        require("dashboard").setup({
            theme = "doom",
            config = {
                header = {
                    "⠀⠀⠀⠀⠈⠙⠂⠀⠀⠀⠀⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⠦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠞⠉⠁⠰⠿⣃⠀⠀⠀⠀⢀⣠⠴⠚⠉⠁",
                    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣆⠀⠀⠀⠀⠀⠀⠀⢰⠃⣤⠀⠀⠀⠊⠁⠀⠀⠀⢐⡯⠀⠀⠀⠀⠀",
                    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣶⣿⣿⡿⠿⠛⠛⠒⠢⢄⡀⠀⠀⠀⠀⠀⠀⠀⠙⠦⢤⠀⠀⠀⠀⠀⠀⠙⠓⠚⠓⣦⠀⠀⢀⡠⠞⠉⠀⠀⠀⠀⠀⠀",
                    "⠸⣦⣄⡀⠀⠠⡄⠀⠀⠀⠀⠀⠀⠀⣠⣶⣿⣿⣿⣿⠏⠀⠀⠳⢄⠀⠀⠀⠀⢈⣛⢤⡀⠀⠀⠀⠀⠀⠀⠘⣇⠀⠀⠀⠀⠀⠀⣀⡤⠞⠃⠀⣀⣸⠇⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⠀⠘⢿⣿⣦⡀⠹⣄⠀⠀⠀⠀⢀⣼⣿⣿⣿⣿⣿⣿⣶⣄⠀⠀⠀⢙⡦⣴⠾⣟⠉⢻⣿⡇⠀⠀⠀⠀⠀⠀⠈⠙⢆⢀⡴⠚⠉⣀⡤⠔⠒⠒⠛⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⢷⣤⣌⢻⣿⣿⣶⣽⣆⢠⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠿⣿⣿⠧⠈⠳⠭⠤⣤⡄⠀⠀⠀⣀⣀⣸⢌⡵⢀⡼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⣒⠙⢿⣿⣿⣿⣿⣿⣿⣯⣧⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠈⠚⠀⠀⠀⢺⣇⠀⢀⣀⣿⣿⣿⠝⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣾⣟⣿⢿⣭⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠾⠛⠋⣹⢶⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⡵⠐⢤⣏⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢦⡻⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡧⣄⢧⣈⣩⣇⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⢿⣛⣻⣿⣿⣿⣿⣾⣿⡿⠯⠽⠋⠑⠢⣄⡀⠀⠀⠀⠀⠀⠀⢀⡴⠋⠉⠓⢄⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠻⡇⠀⠙⠿⣝⣿⠿⢿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠖⠁⠀⠀⠀⠀⠀⠉⠉⠉⠳⣄⠀⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⣿⣿⣿⣿⡷⢿⣿⣿⠟⣿⠇⠀⠉⠀⠀⠀⠀⠉⣛⣿⣿⣿⡶⠶⠶⠒⠒⠒⠶⣶⣶⣤⣄⣀⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢱⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⣿⣿⡿⠋⠀⣿⡿⠋⢠⡟⠀⠀⠀⠀⠀⢠⣶⠿⠏⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠿⣝⣿⣆⠀⠀⠻⢍⠑⠀⠀⠀⠀⠀⠀⢸⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⠿⠋⠀⠀⢸⡟⠁⠀⠈⠁⠀⠀⠀⠀⠀⢸⡟⠀⠐⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⢻⣿⣿⣿⣗⢮⠀⠀⠀⠀⠀⠀⠀⠘⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡄⠀",
                    "⠀⠀⠀⠀⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⠐⠰⠀⠠⠀⠀⢀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⢸⣸⣿⣟⣿⣿⣼⠀⠀⠀⠀⠀⠀⣤⡴⠃⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⠿⠋⠀⠀",
                    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⢃⠈⣀⣀⣀⣀⣠⡴⠚⠁⠀⠀⠠⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠙⢲⠀⠀⠀⠀⠀⢀⣤⡾⠛⠁⠀⠀⠀⠀",
                    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣟⣛⣉⣉⠀⠀⠈⠉⠙⠲⢦⣄⡀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⢠⠞⠀⠀⠀⢠⡶⠟⠁⠀⠀⠀⠀⠀⠀⠀",
                    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠄⠀⢠⣾⡿⢛⣛⣛⣛⡛⠻⠿⣷⣦⣤⣄⣀⣀⠉⠛⣳⣶⣶⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠘⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⠀⠀⠀⠀⠀⠀⠀⠀⠚⠁⢀⣴⣿⣷⣿⣿⣿⣿⣿⣿⣿⣷⣶⣬⣍⡛⠟⣦⣵⠤⣿⡉⠙⢿⣿⣿⣿⣾⣿⣇⠀⠀⠀⠀⢀⣀⠀⠀⣠⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⣿⣄⠀⢙⢓⣄⢻⡝⡌⢯⢿⣿⣷⡀⠀⠀⢸⣈⠙⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⡟⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⡛⠟⠀⢻⢳⠈⢻⣿⢿⣿⣆⠀⠀⡼⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⠀⠀⠀⠀⠀⠀⠀⢀⣾⡟⢰⣿⣿⣿⠿⡿⠛⡛⠛⢿⣿⣿⣿⣿⠁⢹⣿⣿⣿⣿⣷⢻⣷⣄⡤⠋⣸⢦⡤⢿⣟⢻⣿⣦⠞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⠀⠀⠀⠀⠀⠀⠀⢸⣿⢡⣿⣿⡿⣧⣠⣴⠶⢦⡀⠀⠛⣿⣿⣿⣦⠘⣿⣿⣿⣿⣿⣧⠻⣿⣶⣴⠛⢦⣉⠛⢿⣆⢹⣿⣧⠀⠀⣀⡀⠀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⠀⠀⠀⠀⠀⠀⠀⠘⣿⣾⣿⣿⠃⣾⡉⠁⢀⠀⢿⡄⡀⢸⣿⣿⣿⣧⣿⣿⣿⣿⣿⣿⣦⣿⣿⣫⣤⣼⣿⣦⣞⢿⡆⢹⣿⠋⠉⠀⠈⠉⠀⠀⠉⠙⢦⣀⠤⠤⠤⠀⠠⢤⡀",
                    "",
                    "                             ╦   ╔═╗ ╔═╗ ╦╔═ ╔═╗ ╔╦╗   ╦ ╔╗╔                             ",
                    "                             ║   ║ ║ ║   ╠╩╗ ║╣   ║║   ║ ║║║                             ",
                    "                             ╩═╝ ╚═╝ ╚═╝ ╩ ╩ ╚═╝ ═╩╝   ╩ ╝╚╝                             ",
                    "",
                    "",
                },
                center = {
                    {
                        icon = " ",
                        icon_hl = "DashboardIcon",
                        desc = "Find Files                    ",
                        desc_hl = "DashboardDesc",
                        key = "f",
                        key_hl = "DashboardKey",
                        action = "Telescope find_files",
                    },
                    {
                        icon = " ",
                        icon_hl = "DashboardIcon",
                        desc = "Recent Files                  ",
                        desc_hl = "DashboardDesc",
                        key = "r",
                        key_hl = "DashboardKey",
                        action = "Telescope oldfiles",
                    },
                    {
                        icon = " ",
                        icon_hl = "DashboardIcon",
                        desc = "Find Text                     ",
                        desc_hl = "DashboardDesc",
                        key = "g",
                        key_hl = "DashboardKey",
                        action = "Telescope live_grep",
                    },
                    {
                        icon = " ",
                        icon_hl = "DashboardIcon",
                        desc = "File Explorer                 ",
                        desc_hl = "DashboardDesc",
                        key = "e",
                        key_hl = "DashboardKey",
                        action = "NvimTreeToggle",
                    },
                    {
                        icon = " ",
                        icon_hl = "DashboardIcon",
                        desc = "Configuration                 ",
                        desc_hl = "DashboardDesc",
                        key = "c",
                        key_hl = "DashboardKey",
                        action = "edit ~/.config/nvim/init.lua",
                    },
                    {
                        icon = "󰗼 ",
                        icon_hl = "DashboardIcon",
                        desc = "Quit                          ",
                        desc_hl = "DashboardDesc",
                        key = "q",
                        key_hl = "DashboardKey",
                        action = "quit",
                    },
                },
                footer = function()
                    return {
                        "",
                        "✨ You Can Just Do Things ✨",
                    }
                end,
            },
        })
    end,
    dependencies = {
        { "nvim-tree/nvim-web-devicons" },
        { "nvim-telescope/telescope.nvim" },
    },
}
