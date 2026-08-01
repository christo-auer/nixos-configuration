return {
  apply_mail_settings = function()
    vim.opt.textwidth=0
    vim.opt.spell=true
    vim.opt.spelllang='de'
    vim.opt.wrap=true
    vim.opt.columns=100

    vim.api.nvim_set_keymap( 'n', '<leader>m', '', { noremap = false, callback = require('mail_picker').query_mail })
  end
}


