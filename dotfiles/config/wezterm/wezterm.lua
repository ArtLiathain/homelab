local wezterm = require("wezterm")
local constants = require("constants")
local config = wezterm.config_builder()
local commands = require("commands")
local wal_colors = require("wezterm_colours")
-- Font settings
config.font_size = 12
config.line_height = 1

config.enable_kitty_graphics = true

config.colors = {
	foreground = wal_colors.foreground,
	background = wal_colors.background,

	ansi = {
		wal_colors.color0,
		wal_colors.color1,
		"66ff66", -- red (incorrect)
		wal_colors.color3,
		wal_colors.color4,
		wal_colors.color5,
		wal_colors.color6,
		wal_colors.color7,
	},

	brights = {
		wal_colors.color8,
		"ff6666",
		wal_colors.color10,
		wal_colors.color11,
		wal_colors.color12,
		wal_colors.color13,
		wal_colors.color14,
		wal_colors.color15,
	},

	cursor_bg = wal_colors.color2,
	cursor_fg = wal_colors.background,
	selection_bg = wal_colors.color3,
	selection_fg = wal_colors.foreground,
}

-- Appearance
config.window_decorations = "NONE"
config.hide_tab_bar_if_only_one_tab = true
config.window_background_image = constants.bg_image
config.window_background_opacity = 0.8 -- your default
config.window_padding = {
	left = 5, -- or whatever you prefer
	right = 0,
	top = 5,
	bottom = 0, -- 👈 removes bottom padding
}
config.keys = {
	-- This line disables the default CTRL+SHIFT+U binding (CharSelect)
	{
		key = "u",
		mods = "SHIFT|CTRL",
		action = wezterm.action.DisableDefaultAssignment,
	},
	{
		key = ".",
		mods = "SHIFT|CTRL",
		action = wezterm.action.DisableDefaultAssignment,
	},
	{
		key = "d",
		mods = "SHIFT|CTRL",
		action = wezterm.action.DisableDefaultAssignment,
	},
	-- ... (Other custom keybindings you have)
}
-- Silence GUI notifications & warnings
config.exit_behavior = "Close" -- closes child windows silently

config.warn_about_missing_glyphs = false

config.max_fps = 120

-- Commands
wezterm.on("augment-command-palette", function()
	return commands
end)
config.default_prog = { "/usr/bin/tmux", "new-session", "-A", "-s", "main" }
return config
