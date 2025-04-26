local rep = extras.rep
local s = s
local t = t
local i = i

local function empty_file()
    return vim.api.nvim_buf_line_count(0) <= 1
end

return {
    s(
        {
            trig = "#chead",
            show_condition = empty_file,
        }, {
            t({"#pragma once", "#ifndef "}),
            i(1),
            t({"", "#define "}), rep(1),
            t({"", "", "#ifdef __cpluscplus", "extern \"C\" {", "#endif", "", ""}),
            i(0),
            t({"", "", "#ifdef __cpluscplus", "}", "#endif"}),
            t({"", "", "#endif /* "}), rep(1), t(" include guard */")
        }
    ),
    s(
        {
            trig = "#head",
            show_condition = empty_file
        }, {
            t({"#pragma once", "#ifndef "}), i(1), t({"", ""}),
            t({"#define "}), rep(1), t({"", "", ""}),
            i(0), t({"", "", ""}),
            t({"#endif /* "}), rep(1), t(" include guard */")
        }
    ),
    s(
        "#id",
        {
            t({"#ifdef "}), i(1), t({"", ""}),
            i(2), t({"", ""}),
            t({"#endif /* "}), rep(1), t({" */", ""}), i(0)
        }
    ),
    s(
        "#in",
        {
            t({"#ifndef "}), i(1), t({"", ""}),
            i(2), t({"", ""}),
            t({"#endif /* "}), rep(1), t({" */", ""}), i(0)
        }
    ),
    s(
        "#if",
        {
            t({"#if "}), i(1), t({"", ""}),
            i(2), t({"", ""}),
            t({"#endif /* "}), rep(1), t({" */", ""}), i(0)
        }
    )
}
