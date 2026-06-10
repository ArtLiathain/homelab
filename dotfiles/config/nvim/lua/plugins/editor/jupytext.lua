return {
  'GCBallesteros/jupytext.nvim',
  lazy = false, -- Recommended to be false so it catches .ipynb files on startup
  config = function()
    require('jupytext').setup {
      -- Points to the uv-managed venv in your nvim config folder
      custom_cmnds = {
        -- This ensures Neovim uses the 'jupytext' you installed in its own venv
        'python',
        vim.fn.stdpath 'config' .. '/.venv/bin/jupytext',
      },
      style = 'markdown',
      output_extension = 'py',
      force_ft = 'python',
    }
  end,
}
