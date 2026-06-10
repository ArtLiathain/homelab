return {
  'stevearc/oil.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' }, -- optional
  config = function()
    require('oil').setup {
      default_file_explorer = false, -- Don't hijack netrw, let NeoTree handle it
      view_options = {
        show_hidden = true,
      },
    }

    -- Oil keybindings - different from NeoTree
    vim.keymap.set('n', '<leader>o', '<cmd>Oil<cr>', { desc = 'Open parent directory in Oil' })
    vim.keymap.set('n', '<leader>O', '<cmd>Oil --float<cr>', { desc = 'Open Oil in floating window' })
  end,
}
