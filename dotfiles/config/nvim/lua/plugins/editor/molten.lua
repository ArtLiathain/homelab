return {
  'benlubas/molten-nvim',
  version = '^1.0.0',
  build = ':UpdateRemotePlugins',
  init = function()
    vim.g.molten_image_provider = nil
    vim.g.molten_output_win_max_height = 20
    vim.g.molten_use_border_highlights = true

    vim.keymap.set('n', '<leader>mi', ':MoltenInit<CR>')
    vim.keymap.set('n', '<leader>ml', ':MoltenEvaluateLine<CR>')
    vim.keymap.set('n', '<leader>mr', ':MoltenReevaluateCell<CR>')
    vim.keymap.set('v', '<leader>mr', ':<C-u>MoltenEvaluateVisual<CR>gv')
    vim.keymap.set('n', '<leader>os', ':noautocmd MoltenEnterOutput<CR>')
    vim.keymap.set('n', '<leader>oh', ':MoltenHideOutput<CR>')
    vim.keymap.set('n', '<leader>md', ':MoltenDelete<CR>')
  end,
}
