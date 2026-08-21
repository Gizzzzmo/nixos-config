
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = extras.rep
local vim = vim

local function empty_file()
    return vim.api.nvim_buf_line_count(0) <= 1
end

return {
    s(
        {
            trig = "#argparse",
            show_condition = empty_file,
        },
       fmt([[
#!/usr/bin/env python3

# {prog} 
description = """
{desc}
"""

from argparse import ArgumentParser


def main({pos_arg_rep}):
    {main_body}

if __name__ == "__main__":
    parser = ArgumentParser(prog="{prog}", description=description)
    _ = parser.add_argument("{pos_arg}")
    {other_args}

    args = parser.parse_args()
    main(args.{pos_arg_rep})
]], {
           prog = i(1, "app name"),
           desc = i(2),
           pos_arg = i(3, "arg"),
           pos_arg_rep = rep(3),
           other_args = i(4),
           main_body = i(0, "pass")
       }, {
           repeat_duplicates = true
       })
    )
}

