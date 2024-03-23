return {
  -- Code outline window for skimming and quick navigation
  'stevearc/aerial.nvim',
  config = function()
    require('aerial').setup {
      log_level = 'info',
      backends = { 'treesitter', 'lsp' },
      highlight_on_hover = true,
      attach_mode = 'global',
      filter_kind = {
        'Class',
        'Field',
        'Variable',
        'Constructor',
        'Enum',
        'Function',
        'Interface',
        'Module',
        'Method',
        'Struct',
      },
    }

    -- set keymaps
    vim.keymap.set('n', '<leader>va', '<cmd>AerialToggle!<CR>', { desc = '[V]iew [A]erial' })
  end,
}
