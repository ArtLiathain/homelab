-- lua/lspconfig/lua_ls.lua

-- The structure MUST be a simple table containing ONLY the
-- server-specific keys (like 'settings' or 'cmd').
-- It MUST NOT contain shared keys like 'on_attach' or 'capabilities'.

return {
  -- This is the required key for LUA_LS server configuration:
  settings = {
    Lua = {
      -- Ensure these keys are correct for the Lua language server
      completion = {
        callSnippet = 'Replace',
      },
      diagnostics = {
        -- Example of a key you can easily verify is working
        globals = { 'vim' },
      },
      workspace = {
        -- Key used by the lua_ls to tell it where to look for files
        library = {
          -- This is standard for Neovim config files
          vim.fn.stdpath 'config' .. '/lua',
        },
      },
    },
  },

  -- ONLY if you need to override the executable path (uncommon with Mason)
  -- cmd = { 'lua-language-server' },
}
