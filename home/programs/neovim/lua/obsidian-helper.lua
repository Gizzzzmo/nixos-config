local function switch_workspace_cwd()
    -- file at ~/.config/nvim/.obsidian-workspace
    local current_workspace = vim.fn.expand("~/.config/nvim/.obsidian-workspace")
    local saved_workspace_name = nil
    if vim.fn.filereadable(current_workspace) == 1 then
        saved_workspace_name = vim.fn.readfile(current_workspace)[1]
    end

    local workspaces = Obsidian.workspaces
    local cwd = vim.fn.getcwd()
    for _, workspace in pairs(workspaces) do
        local path =  workspace.path.filename
        if saved_workspace_name and workspace.name == saved_workspace_name then
            vim.notify("Switching to saved Obsidian workspace: " .. workspace.name)
            require('obsidian').Workspace.set(workspace)
        end
        if cwd:find(path, 1, true) == 1 then
            vim.notify("Switching to Obsidian workspace: " .. workspace.name)
            vim.fn.writefile({workspace.name}, current_workspace)
            require('obsidian').Workspace.set(workspace)
            return
        end
    end
end

return {switch_workspace_cwd=switch_workspace_cwd}
