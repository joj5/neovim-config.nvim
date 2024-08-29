return {
  'diepm/vim-rest-console',
  dependencies = {
    'stedolan/jq',
  },
  config = function()
    -- turn off default key binding
    vim.g.vrc_set_default_mapping = 0
    -- default response content type
    vim.g.vrc_response_default_content_type = 'application/json'
    -- output buffer name
    vim.g.vrc_output_buffer_name = '_OUTPUT.json'
    -- format response buffer
    vim.g.vrc_auto_format_response_patterns = {
      json = 'jq',
    }

    -- set key maps
    vim.keymap.set('n', '<leader>xr', ':call VrcQuery()<cr>', { desc = 'Execute rest request' })
  end,
}
