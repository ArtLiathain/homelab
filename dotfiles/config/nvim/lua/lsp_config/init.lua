local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)
local navic = require 'nvim-navic'

-- 1. SERVER LIST
-- List all servers you want to configure and install via Mason
local servers_to_configure = {
  'lua_ls',
  'gopls',
  'ts_ls',
  'pyright',
  'zls',
  'rust_analyzer',
  'clangd',
  'omnisharp',
  'jsonls',
  'taplo',
  'yamlls',
  'marksman',
  'htmx',
  'bashls',
  'cssls',
  'tinymist',
  'nil_ls',
}

-- 2. GLOBAL DIAGNOSTICS CONFIG
vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
} -- 3. COMMON ON_ATTACH FUNCTION (Keymaps)
local on_attach = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

  local map = function(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
  end
  map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
  map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
  map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
  map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
  map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

  if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, bufnr) then
    local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = bufnr,
      group = highlight_augroup,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = bufnr,
      group = highlight_augroup,
      callback = vim.lsp.buf.clear_references,
    })
  end
  if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, bufnr) then
    map('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr })
    end, '[T]oggle Inlay [H]ints')
  end
end

-- 4. SERVER SETUP LOOP (Handles Custom Config Merging)
for _, server in ipairs(servers_to_configure) do
  local success, config_module = pcall(require, 'lsp_config.' .. server)

  -- If the custom file exists, use its table; otherwise, use an empty table
  local server_config = (success and type(config_module) == 'table') and config_module or {}

  -- Apply the shared settings (on_attach and capabilities)
  server_config.capabilities = capabilities
  server_config.on_attach = on_attach

  -- Set up the server
  -- Set up the server config (overrides/extends the base config)
  vim.lsp.config(server, server_config)

  -- Enable the server config to start on the correct filetypes
  vim.lsp.enable(server)
end

-- Return the list of servers so the plugins file can tell Mason what to install
return servers_to_configure
