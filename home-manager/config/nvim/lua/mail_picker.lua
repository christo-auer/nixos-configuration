local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

M = {
  mail_picker = function(query, opts)
    pickers.new(opts, {
      prompt_title = "mail query",
      finder = finders.new_async_job({
        command_generator = function()
          return { vim.fn.stdpath('config') .. "/query-address.sh", query  }
        end
      }),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.api.nvim_put({ selection[1] } , "", false, true)
        end)
        return true
      end,    sorter = conf.generic_sorter(opts),
    }):find()
  end,

  query_mail = function()
    vim.fn.inputsave()
    local query = vim.fn.input("Query: ")
    vim.fn.inputrestore()

    if (query == '') then
      return
    end

    M.mail_picker(query)

  end

}

return M
