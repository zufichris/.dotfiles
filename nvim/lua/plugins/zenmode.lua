return {
    "folke/zen-mode.nvim",
    opts = {
        window = {
            backdrop = 0.95,
            width = 120,
            height = 1,
            options = {
                -- signcolumn = "no",
                -- number = false,
                -- relativenumber = false,
                -- cursorline = false,
                -- cursorcolumn = false,
                -- foldcolumn = "0",
                -- list = false,
            },
        },
        plugins = {
            options = {
                enabled = true,
                ruler = false,
                showcmd = false,
                laststatus = 0,
            },
            twilight = { enabled = true },
            gitsigns = { enabled = false },
            tmux = { enabled = false },
            todo = { enabled = false },
        },
        on_open = function(win)
            print("zen mode enabled")
        end,
        on_close = function()
            print("zen mode disabled")
        end,
    },
    config = function()
        vim.keymap.set("n", "<leader>zz", function()
            require("zen-mode").setup({
                window = {
                    width = 90,
                    options = {},
                },
            })
            require("zen-mode").toggle()
            vim.wo.wrap = false
            vim.wo.number = true
            vim.wo.rnu = true
        end, { desc = "Zen mode (minimal UI)" })

        vim.keymap.set("n", "<leader>zZ", function()
            require("zen-mode").setup({
                window = {
                    width = 80,
                    options = {},
                },
            })
            require("zen-mode").toggle()
            vim.wo.wrap = false
            vim.wo.number = false
            vim.wo.rnu = false
            vim.opt.colorcolumn = "0"
        end, { desc = "Zen mode (distraction-free)" })
    end,
}
