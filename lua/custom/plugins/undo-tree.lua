return {
  'mbbill/undotree',
  config = function()
    vim.keymap.set('n', '<leader>vu', '<cmd>UndotreeToggle<cr>', { desc = '[V]iew [U]ndo tree view' })
  end,
}
