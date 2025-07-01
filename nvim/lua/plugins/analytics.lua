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
        opts={
            session_key="4987372d-9c68-40d9-898c-a1428d2a1d90"
        }
    },
}
