return {
    {
        "wakatime/vim-wakatime",
        opts = {
            lazy = false,
        },
    },
    {
        "voltycodes/areyoulockedin.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
    },
}

