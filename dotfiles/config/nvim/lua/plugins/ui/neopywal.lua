return {
  'RedsXDD/neopywal.nvim',
  name = 'neopywal',
  lazy = false,
  priority = 1000,
  config = function()
    require('neopywal').setup {
      custom_colors = {},
      custom_highlights = {},
      use_palette = {
        light = 'wallust',
        dark = 'wallust',
      },
      transparent_background = true,
    }
  end,
}
