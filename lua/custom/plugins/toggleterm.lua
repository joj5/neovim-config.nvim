--[[
--
--
--  toggle the terminal
--
--
--]]

return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    require('toggleterm').setup {
      -- size can be a number or function which is passed the current terminal
      --size = 20 |
      size = function(term)
        if term.direction == 'horizontal' then
          return 15
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.6
        end
      end,
      open_mapping = [[<leader>vt]],
      insert_mappings = false,
      --direction = 'vertical' | 'horizontal' | 'tab' | 'float',
      direction = 'vertical',
      close_on_exit = true, -- close the terminal window when the process exits
      shell = '/usr/bin/bash', -- change the default shell
    }

    -- set key maps
    vim.keymap.set('n', '<leader>vt', '<cmd>ToggleTerm<cr>', { desc = '[V]iew [T]erminal' })
  end,
}
