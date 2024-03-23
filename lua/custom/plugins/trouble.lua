return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('trouble').setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }

    -- set keymaps
    vim.keymap.set('n', '<leader>vp', '<cmd>TroubleToggle<cr>', { desc = '[V]iew [P]roblems' })
  end,
}
