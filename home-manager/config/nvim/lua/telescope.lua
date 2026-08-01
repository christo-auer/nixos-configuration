local action = require "telescope.actions"
require('telescope').setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      n = {
        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        ["t"] = action.toggle_selection + action.move_selection_next,
        ["T"] = action.toggle_all,
        ["D"] = action.delete_buffer + action.move_selection_next,
        ["q"] = action.close,
        ["s"] = action.select_horizontal,
        ["v"] = action.select_vertical
      }
    },
    path_display = { 'shorten' }
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  }
}
