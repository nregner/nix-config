-- https://wezfurlong.org/wezterm/config/files.html
local wezterm = require("wezterm")
return {
	term = "wezterm",
	font = wezterm.font("JetBrainsMono Nerd Font"),
	font_size = 11.0,
	color_scheme = "Catppuccin Mocha",
	hide_tab_bar_if_only_one_tab = true,
	default_prog = { "zsh", "--login", "-c", "tmux attach -t dev || tmux new -s dev" },
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
}
