local function override_highlights()
    local colors = require("gruvbox").palette
    return {
        AvanteSidebarWinSeparator = { link = "FloatBorder" },
        AvanteSidebarWinHorizontalSeparator = { link = "FloatBorder" },
        BlinkCmpDocBorder = { link = "GruvboxGray" },
        BlinkCmpMenu = { link = "Normal" },
        BlinkCmpMenuBorder = { link = "GruvboxGray" },
        BlinkCmpLabelDeprecated = { link = "DiagnosticDeprecated" },
        BlinkCmpMenuSelection = { link = "CursorLine" },
        BlinkCmpSignatureHelpBorder = { link = "GruvboxGray" },
        BlinkCmpSignatureHelpActiveParameter = { link = "Visual" },
        DiffAdd = { bg = "#34381b" },
        DiffChange = { bg = "#0e363e" },
        DiffDelete = { bg = "#402120" },
        CmpItemAbbrMatchFuzzy = { link = "CmpIntemAbbrMatch" },
        CmpItemAbbrDeprecated = { link = "DiagnosticDeprecated" },
        CoverageCovered = { link = "GruvboxGreen" },
        CoverageUncovered = { link = "GruvboxRed" },
        CoveragePartial = { link = "GruvboxOrange" },
        CoverageSummaryHeader = { link = "GruvboxBlueBold" },
        DapStoppedLine = { default = true, link = "Visual" },
        DapUIPlayPause = { link = "GruvboxGreen" },
        DapUIRestart = { link = "GruvboxGreen" },
        DapUIStepInto = { link = "GruvboxAqua" },
        DapUIStepOver = { link = "GruvboxAqua" },
        DapUIStepOut = { link = "GruvboxAqua" },
        DapUIStepBack = { link = "GruvboxAqua" },
        DapUIStop = { link = "GruvboxRed" },
        Delimiter = { link = "GruvboxFg1" },
        NeotestDir = { link = "GruvboxAqua" },
        NeotestFile = { link = "GruvboxBlue" },
        NeotestFailed = { link = "GruvboxRed" },
        NeotestIndent = { link = "GruvboxFg1" },
        NeotestMark = { link = "GruvboxOrange" },
        NeotestPassed = { link = "GruvboxGreen" },
        NeotestTarget = { link = "GruvboxBlue" },
        NeotestFocused = { link = "GruvboxBlue" },
        NeotestRunning = { link = "GruvboxYellow" },
        NeotestSkipped = { link = "GruvboxOrange" },
        NeotestNamespace = { link = "GruvboxMagenta" },
        NeotestWatching = { link = "GruvboxYellow" },
        NeotestAdapterName = { link = "GruvboxGreen" },
        NeotestExpandMarker = { link = "NeotestIndent" },
        NeotestWinSelect = { link = "GruvboxBlue" },
        RenderMarkdownCode = { bg = colors.dark0 },
        FloatBorder = { link = "GruvboxGray" },
        FzfLuaDirPart = { link = "GruvboxBg2" },
        PmenuSel = { link = "TabLineSel" },
        WinBarNC = { link = "WinBar" },
        NormalSB = { link = "Normal" },
        Match = { fg = colors.bright_orange },
        Folded = { bg = "None" },
        UfoFoldedBg = { link = "MatchBackground" },
        StatusLine = { bg = "None" },
        Keyword = { fg = colors.bright_red, italic = true },
        ["@keyword.import"] = { link = "@keyword" },
        ["@namespace"] = { link = "GruvboxAqua" },
        ["@lsp.type.variable"] = {},
        ["@lsp.mod.readonly"] = { link = "GruvboxPurple" },
        ["@include"] = {},
    }
end
return {
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function()
            local transparent = false

            local function apply()
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
                    contrast = nil,
                    palette_overrides = {},
                    overrides = override_highlights(),
                    dim_inactive = false,
                    transparent_mode = transparent,
                })
                vim.cmd("colorscheme gruvbox")
            end

            apply()

            vim.api.nvim_create_user_command("Togglebg", function()
                transparent = not transparent
                apply()
                print("Transparent mode: " .. (transparent and "ON" or "OFF"))
            end, {})

            vim.keymap.set("n", "<leader>bt", "<cmd>Togglebg<CR>", { desc = "Toggle Gruvbox Background" })
        end,
    },
    {
        "norcalli/nvim-colorizer.lua",
        opts = {},
    },
}
