return {
  'NickvanDyke/opencode.nvim',
  dependencies = {
    { 'folke/snacks.nvim', opts = { input = {}, picker = {}, terminal = { modifiable = true } } },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {}

    vim.o.autoread = true

    local function set_opencode_modifiable()
      -- Ensure 'modifiable' is set to true for the Opencode buffer
      vim.opt_local.modifiable = true
    end

    -- Create the Autocommand to run the function when the Opencode window is entered
    -- This runs AFTER the plugin has finished setting up the buffer's properties.
    vim.api.nvim_create_autocmd('BufWinEnter', {
      pattern = '*opencode-output*',
      callback = set_opencode_modifiable,
    })

    vim.keymap.set({ 'n', 'x' }, '<C-a>', function()
      require('opencode').ask('@this: ', { submit = true })
    end, { desc = 'Ask opencode' })
    vim.keymap.set({ 'n', 'x' }, '<C-x>', function()
      require('opencode').select()
    end, { desc = 'Execute opencode action…' })
    vim.keymap.set({ 'n', 't' }, '<leader>.', function()
      require('opencode').toggle()
    end, { desc = 'Toggle opencode' })

    vim.keymap.set({ 'n', 'x' }, 'go', function()
      return require('opencode').operator '@this '
    end, { expr = true, desc = 'Add range to opencode' })
    vim.keymap.set('n', 'goo', function()
      return require('opencode').operator '@this ' .. '_'
    end, { expr = true, desc = 'Add line to opencode' })

    vim.keymap.set('n', '<C-S-u>', function()
      require('opencode').command 'session.half.page.up'
    end, { desc = 'opencode half page up' })
    vim.keymap.set('n', '<C-S-D>', function()
      require('opencode').command 'session.half.page.down'
    end, { desc = 'opencode half page down' })

    vim.keymap.set('n', '+', '<C-a>', { desc = 'Increment', noremap = true })
    vim.keymap.set('n', '-', '<C-x>', { desc = 'Decrement', noremap = true })
  end,
}
