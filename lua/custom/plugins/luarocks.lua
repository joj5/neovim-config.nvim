return {
  'vhyrro/luarocks.nvim',
  opts = {
    rocks = { 'lua-curl', 'nvim-nio', 'mimetypes', 'xml2lua' }, -- Specify LuaRocks packages to install
  },
  priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
  -- lazy = false,
  -- config = true,
}
