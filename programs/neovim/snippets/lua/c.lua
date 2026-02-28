
local rep = extras.rep
local s = s
local t = t
local i = i
local fmt = require("luasnip.extras.fmt").fmt

local function empty_file()
    return vim.api.nvim_buf_line_count(0) <= 1
end

return {
    s(
        {
            trig = "#chead",
            show_condition = empty_file,
        }, {
            t({"#ifndef "}),
            i(1),
            t({"", "#define "}), rep(1),
            t({"", "", "#ifdef __cplusplus", "extern \"C\" {", "#endif", "", ""}),
            i(0),
            t({"", "", "#ifdef __cplusplus", "}", "#endif"}),
            t({"", "", "#endif // "}), rep(1), t(" include guard")
        }
    )
}
