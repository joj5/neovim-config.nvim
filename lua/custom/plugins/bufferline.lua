return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    local bufferline = require 'bufferline'
    bufferline.setup {
      options = {
        numbers = 'buffer_id',
        right_mouse_command = 'vertical sbuffer %d',
      },
    }

    -- set key maps
    vim.keymap.set('n', '<F2>', '<cmd>bprevious<CR>', { desc = 'Previous Buffer' })
    vim.keymap.set('n', '<F3>', '<cmd>bnext<CR>', { desc = 'Next Buffer' })
    vim.keymap.set('n', '<leader>bd', ':bn<cr>:bd#<CR>', { desc = '[B]uffer [D]elete current buffer' })
  end,
}
