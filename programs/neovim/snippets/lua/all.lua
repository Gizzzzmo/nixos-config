local rep = extras.rep
local s = s
local t = t
local i = i
local fmt = fmt

local function on_first_line()
    return vim.api.nvim_win_get_cursor(0)[1] == 1
end
return {
    s(
        {
            trig = "#!shebang",
            show_condition = on_first_line,
        }, {
            t("#!/usr/bin/env "), i(0)
        }
    )
}
