
local conf = require("telescope.config").values
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local pickers = require "telescope.pickers"
local sorters = require "telescope.sorters"

local function starts_with(str, prefix)
    return string.sub(str, 1, string.len(prefix)) == prefix
end

local function get_relative_buffer_path()
    local full_path = vim.api.nvim_buf_get_name(0)
    -- In case one of the following conditions apply, use the cwd.
    -- - We aren't in a file buffer.
    -- - The filename is empty.
    if full_path == nil or
        full_path == '' then
        return '.'
    end

    -- convert relative paths to absolute paths
    local absolute_path = io.popen("realpath '" .. full_path .. "'", 'r'):read('*a')
    full_path = absolute_path:gsub('[\n\r]*$', '') -- Remove trailing newline 

    -- Return the relative path of the buffer to the current cwd.
    -- That's what proxmity sort expects.
    local cwd = vim.fn.getcwd()
    local relative_path = full_path
    if starts_with(full_path, cwd) then
        relative_path = string.sub(relative_path, string.len(cwd) + 2, -1)
    else
        return '.'
    end

    -- Fallback to the cwd if:
    -- - The path equals the cwd.
    -- - We're in a neo-tree buffer
    if relative_path == '' or starts_with(full_path, 'neo-tree') then
        return '.'
    end
    return relative_path
end

-- A file picker that sorts entries based on the proximity of files relative to
-- the file path of the current buffer.
-- Requires the `proximity-sort` and `fd` binaries to be present.
local proximity_files = function(opts)
    local path = get_relative_buffer_path()
    -- print(string.format("Relative proximity path: '%s'", path))

    local live_fd = finders.new_job(
        function(prompt)
            if not prompt or prompt == "" then
                prompt = "."
            end

            local cmd = {
                "bash",
                "-c",
                string.format('fd --full-path --type f %s . | proximity-sort %s', prompt, path),
            }
            return cmd
        end,
        opts.entry_maker or make_entry.gen_from_file(opts),
        opts.max_results,
        opts.cwd
    )

    pickers
    .new(opts, {
        prompt_title = "Proximity Files",
        finder = live_fd,
        previewer = conf.file_previewer(opts),
        sorter = sorters.highlighter_only(opts),
        push_cursor_on_edit = true,
        __locations_input = true,
    })
    :find()
end

return {proximity_files = proximity_files, get_relative_buffer_path = get_relative_buffer_path}
