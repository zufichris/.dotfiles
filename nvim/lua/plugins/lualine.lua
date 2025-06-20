-- Returns a formatted string for the status line showing either active LSP progress messages or the names of connected LSP clients.
-- If there are ongoing LSP progress messages, they are displayed prefixed by an LSP icon; otherwise, the names of active LSP clients are shown in brackets with the same prefix.
local function lsp_clients()
    return require("lsp-progress").progress({
        format = function(messages)
            local active_clients = vim.lsp.get_clients()
            if #messages > 0 then
                return " LSP:" .. table.concat(messages, " ")
            end
            local client_names = {}
            for i, client in ipairs(active_clients) do
                if client and client.name ~= "" then
                    table.insert(client_names, "[" .. client.name .. "]")
                end
            end
            return " LSP:" .. table.concat(client_names, " ")
        end,
    })
end

return {
    {
        "linrongbin16/lsp-progress.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lsp-progress").setup()
        end,
    },
    {
        event = "VeryLazy",
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "linrongbin16/lsp-progress.nvim",
        },
        opts = {
            options = {
                theme = "auto",
                globalstatus = true,
                icons_enabled = true,
                disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = {
                    --lsp_clients,
                    "branch",
                    { "diff", symbols = { added = " ", modified = "柳 ", removed = " " } },
                    {
                        "diagnostics",
                        sources = { "nvim_diagnostic" },
                        symbols = { error = " ", warn = " ", info = " " },
                    },
                },
                lualine_c = { "filename" },
                lualine_x = { "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        },
        config = function(_, opts)
            require("lualine").setup(opts)
            -- listen lsp-progress event and refresh lualine
            vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
            vim.api.nvim_create_autocmd("User", {
                pattern = "LspProgressStatusUpdated",
                group = "lualine_augroup",
                callback = require("lualine").refresh,
            })
        end,
    },
}
