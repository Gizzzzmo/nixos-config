local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")

local function add_to_tree(tree, parts, added, deleted)
  local node = tree
  for i = 1, #parts - 1 do
    local dirname = parts[i]
    if not node[dirname] then
      node[dirname] = {}
    end
    node = node[dirname]
  end
  node[parts[#parts]] = { added = added, deleted = deleted }
end

local function sort_node(node)
  local dirs, files = {}, {}
  for k, v in pairs(node) do
    if v.added ~= nil then
      table.insert(files, k)
    else
      table.insert(dirs, k)
    end
  end
  table.sort(dirs)
  table.sort(files)
  return dirs, files
end

local function render_tree(node, indent, result)
  local dirs, files = sort_node(node)
  for _, dir in ipairs(dirs) do
    table.insert(result, string.rep("  ", indent) .. dir .. "/")
    render_tree(node[dir], indent + 1, result)
  end
  for _, file in ipairs(files) do
    local child = node[file]
    local stat = ""
    if child.added > 0 or child.deleted > 0 then
      stat = string.format("  +%d/-%d", child.added, child.deleted)
    end
    table.insert(result, string.rep("  ", indent) .. file .. stat)
  end
end

local function changed_files_tree(ref)
  local raw = vim.fn.systemlist("git diff --numstat " .. ref .. " 2>/dev/null | head -500")
  if vim.v.shell_error ~= 0 then
    return { "Error fetching changed files" }
  end

  local tree = {}
  for _, line in ipairs(raw) do
    local added, deleted, filepath = line:match("^(%d+)%s+(%d+)%s+(.+)$")
    if added and deleted and filepath then
      local parts = vim.split(filepath, "/")
      add_to_tree(tree, parts, tonumber(added), tonumber(deleted))
    end
  end

  local result = {}
  render_tree(tree, 0, result)
  if #result == 0 then
    return { "No files changed" }
  end
  return result
end

local git_ref_picker = function(opts)
  opts = opts or {}

  local ok, _ = pcall(vim.fn.system, "git rev-parse --git-dir 2>/dev/null")
  if not ok then
    vim.notify("Not in a git repository", vim.log.levels.ERROR)
    return
  end

  local ref_previewer = previewers.new_buffer_previewer({
    define_preview = function(self, entry, _status)
      local line = entry.value or entry[1]
      local ref = line and line:match("^%S+")
      if not ref then return end
      local lines = changed_files_tree(ref)
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
    end,
  })

  pickers.new(opts, {
    prompt_title = "Git Refs",
    finder = finders.new_oneshot_job(
      { "bash", "-c", "git log --all --oneline --decorate=short --color=never 2>/dev/null | head -5000" },
      opts
    ),
    sorter = conf.generic_sorter(opts),
    previewer = ref_previewer,
    attach_mappings = function(prompt_bufnr, _map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          local line = selection.value or selection[1]
          if line then
            local ref = line:match("^%S+")
            if ref then
              vim.cmd("DiffviewOpen " .. ref)
            end
          end
        end
      end)
      return true
    end,
  }):find()
end

return { git_ref_picker = git_ref_picker }
