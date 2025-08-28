local function switch_workspace_cwd()
    local obsidian = require('obsidian')
    local workspaces = Obsidian.opts.workspaces
    local workspace_cwd = obsidian.Workspace.get_workspace_for_dir(workspaces)

    if not workspace_cwd then
        return
    end

    -- TODO: fix this
    obsidian.Workspace.switch(workspace_cwd)
end

return {switch_workspace_cwd=switch_workspace_cwd}
