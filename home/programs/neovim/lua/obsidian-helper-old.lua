local function switch_workspace_cwd()
    local obsidian = require('obsidian')
    local workspaces = obsidian._client.opts.workspaces
    local workspace_cwd = obsidian.Workspace.get_workspace_for_cwd(workspaces)

    if not workspace_cwd then
        return
    end

    obsidian.Client.switch_workspace(obsidian._client, workspace_cwd)
end

return {switch_workspace_cwd=switch_workspace_cwd}
