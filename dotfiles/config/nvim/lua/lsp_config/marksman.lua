-- The structure MUST be a simple table containing ONLY the
- - server-specific keys (like 'settings' or 'cmd').
-- It MUST NOT contain shared keys like 'on_attach' or 'capabilities'.

return {
  -- This is the specific key to silence all diagnostics for Marksman:
  handlers = {
    -- We define an empty function for publishDiagnostics.
    -- This effectively "swallows" all errors, warnings, and hints.
    ['textDocument/publishDiagnostics'] = function() end,
  },

  -- Marksman settings (usually empty as Marksman uses .marksman.toml)
  settings = {
    marksman = {
      -- You can add marksman-specific settings here if needed later
    },
  },

  -- The default command used by Marksman
  -- cmd = { "marksman", "server" },
}
