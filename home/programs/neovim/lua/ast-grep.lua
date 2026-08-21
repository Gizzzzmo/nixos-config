return function ()
    local query = vim.fn.input("Query: ", "")
    require("fzf-lua").fzf_exec(

        "ast-grep --context 0 --heading never --pattern '" .. query .."' 2>/dev/null",
        {
            exec_empty_query=false,
            actions = {
                ["default"] = require("fzf-lua").actions.file_edit,
            },
            previewer = "builtin"
        }
    )

end
