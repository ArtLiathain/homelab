return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },

  dependencies = {
    -- CRITICAL: Mason must be initialized
    { 'mason-org/mason.nvim', config = true },
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Dependencies for UI/Capabilities
    { 'j-hui/fidget.nvim', opts = {} },
    'saghen/blink.cmp',
    'SmiteshP/nvim-navic',
  },

  config = function()
    local servers_to_install = require 'lsp_config.init'
    require('mason-lspconfig').setup {
      ensure_installed = servers_to_install,
    }
    require('mason-tool-installer').setup { ensure_installed = servers_to_install }
  end,
}
