local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup {
  -- 1. The "spec" section is ONLY for plugins and imports
  spec = {
    { import = 'plugins.ui.neopywal' },
    { import = 'plugins.ui.catppuccin' },
    { import = 'plugins.git.lazygit' },
    { import = 'plugins.git.gitsigns' },
    { import = 'plugins.editor.wakatime' },
    { import = 'plugins.editor.mini' },
    { import = 'plugins.editor.lint' },
    { import = 'plugins.editor.opencode' },
    { import = 'plugins.editor.autopairs' },
    { import = 'plugins.editor.typst-preview' },
    { import = 'plugins.editor.autoformat' },
    { import = 'plugins.editor.todo-comments' },
    { import = 'plugins.editor.which-key' },
    { import = 'plugins.editor.jupytext' },
    { import = 'plugins.editor.molten' },
    { import = 'plugins.editor.autocomplete' },
    { import = 'plugins.editor.oil' },
    { import = 'plugins.editor.harpoon' },
    { import = 'plugins.navigation.telescope' },
    { import = 'plugins.navigation.treesitter' },
    { import = 'plugins.lsp.lazydev' },
    { import = 'plugins.lsp.lsp' },
    { import = 'plugins.debug.dap' },
  },

  -- 2. The "ui" section is a TOP-LEVEL option for lazy.nvim itself
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
}
