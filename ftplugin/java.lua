local status, jdtls = pcall(require, 'jdtls')
if not status then
  return
end

local extendedClientCapabilities = jdtls.extendedClientCapabilities

local share_dir = os.getenv 'HOME' .. '/.local/share'
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = share_dir .. '/eclipse/' .. project_name

-- Set proper Java executable
local java_cmd = 'java'
local mason_registry = require 'mason-registry'

-- vim.fn.glob Is needed to set paths using wildcard (*)
local bundles = {
  vim.fn.glob(mason_registry.get_package('java-debug-adapter'):get_install_path() .. '/extension/server/com.microsoft.java.debug.plugin-*.jar'),
}

vim.list_extend(bundles, vim.split(vim.fn.glob(mason_registry.get_package('java-test'):get_install_path() .. '/extension/server/*.jar'), '\n'))

local jdtls_path = mason_registry.get_package('jdtls'):get_install_path()

local config = {
  cmd = {
    java_cmd,
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms512m',
    '-Xmx2048m',
    '--add-modules=ALL-SYSTEM',
    '--add-opens',
    'java.base/java.util=ALL-UNNAMED',
    '--add-opens',
    'java.base/java.lang=ALL-UNNAMED',
    '-javaagent:' .. share_dir .. '/nvim/mason/packages/jdtls/lombok.jar',
    '-jar',
    vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
    '-configuration',
    jdtls_path .. '/config_linux',
    '-data',
    workspace_dir,
  },
  flags = {
    debounce_text_changes = 150,
    allow_incremental_sync = true,
  },

  root_dir = jdtls.setup.find_root { '.metadata', '.git', 'pom.xml', 'build.gradle', 'gradlew', 'mvnw' },

  on_init = function(client)
    if client.config.settings then
      client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
    end
  end,

  init_options = {
    bundles = bundles,
  },
  capabilities = require('cmp_nvim_lsp').default_capabilities(),

  on_attach = function(client, bufnr)
    local border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }
    local signature_cfg = {
      bind = true, -- This is mandatory, otherwise border config won't get registered.
      -- If you want to hook lspsaga or other signature handler, pls set to false
      doc_lines = 2, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
      -- set to 0 if you DO NOT want any API comments be shown
      -- This setting only take effect in insert mode, it does not affect signature help in normal
      -- mode, 10 by default

      floating_window = true, -- show hint in a floating window, set to false for virtual text only mode
      hint_enable = false, -- virtual hint enable
      hint_prefix = '🐼 ', -- Panda for parameter
      hint_scheme = 'String',
      use_lspsaga = false, -- set to true if you want to use lspsaga popup
      hi_parameter = 'Search', -- how your parameter will be highlight
      max_height = 12, -- max height of signature floating_window, if content is more than max_height, you can scroll down
      -- to view the hiding contents
      max_width = 120, -- max_width of signature floating_window, line will be wrapped if exceed max_width
      handler_opts = {
        border = 'single', -- double, single, shadow, none
      },
      -- deprecate !!
      -- decorator = {"`", "`"}  -- this is no longer needed as nvim give me a handler and it allow me to highlight active parameter in floating_window
    }

    local shp = client.server_capabilities.signatureHelpProvider
    if shp == true or (type(shp) == 'table' and next(shp) ~= nil) then
      require('lsp_signature').on_attach(signature_cfg, bufnr)
    end

    local hp = client.server_capabilities.hoverProvider
    if hp == true or (type(hp) == 'table' and next(hp) ~= nil) then
      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
    end

    if client.name == 'jdtls' then
      require('which-key').register {
        ['<leader>de'] = { '<cmd>DapContinue<cr>', '[JDLTS] Show debug configurations' },
        ['<leader>ro'] = { "<cmd>lua require'jdtls'.organize_imports()<cr>", '[JDLTS] Organize imports' },

        -- Debug
        ['<leader>f'] = {
          name = '[DAP debug]',
          R = { "<cmd>lua require'dap'.run()<cr>", '[DAP] Run' },
          e = { "<cmd>lua require'dap'.run_last()<cr>", '[DAP] Debug last' },
          E = { '<cmd>Telescope dap configurations<cr>', '[DAP] Show debug configurations' },
          k = { '<cmd>DapTerminate<cr>', '[DAP] Terminate' },
          b = { '<cmd>DapToggleBreakpoint<cr>', '[DAP] Toggle breakpoint' },
          B = {
            "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>",
            '[DAP] Set conditional breakpoint',
          },
          l = {
            "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>",
            '[DAP] Set log point breakpoint',
          },
          c = { '<cmd>DapContinue<cr>', '[DAP] Continue' },
          v = { '<cmd>DapStepOver<cr>', '[DAP] Step over' },
          i = { '<cmd>DapStepInto<cr>', '[DAP] Step into' },
          o = { '<cmd>DapStepOut<cr>', '[DAP] Step out' },
          x = { "<cmd>lua require('dapui').eval()<cr>", '[DAPUI] Evaluate}' },
          p = { '<cmd>DapToggleRepl<cr>', '[DAP] Repl open' },
          u = { "<cmd>lua require'dapui'.toggle()<cr>", '[DAPUI] Toggle debugging UI' },
          s = { '<cmd>Telescope dap list_breakpoints<cr>', '[TELESCOPE DAP] Show all breakpoints' },
          w = { '<cmd>Telescope dap variables<cr>', '[TELESCOPE DAP] Wariables' },
        },
      }
      jdtls.setup_dap { hotcodereplace = 'auto' }
      -- jdtls.setup.add_commands() -- this line is deprecated
      -- Auto-detect main and setup dap config
      require('jdtls.dap').setup_dap_main_class_configs {
        config_overrides = {
          vmArgs = '-Dspring.profiles.active=local',
        },
      }
    end
  end,

  settings = {
    java = {
      signatureHelp = {
        enabled = true,
      },
      extendedClientCapabilities = extendedClientCapabilities,
      saveActions = {
        organizeImports = true,
      },
      completion = {
        maxResults = 20,
        favoriteStaticMembers = {
          'org.hamcrest.MatcherAssert.assertThat',
          'org.hamcrest.Matchers.*',
          'org.hamcrest.CoreMatchers.*',
          'org.junit.jupiter.api.Assertions.*',
          'java.util.Objects.requireNonNull',
          'java.util.Objects.requireNonNullElse',
          'org.mockito.Mockito.*',
          'org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.*',
          'org.assertj.core.api.AssertionsForClassTypes.*',
        },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      codeGeneration = {
        toString = {
          template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
        },
      },
      format = {
        settings = {
          url = '~/Templates/java-styles/java-google-formatter.xml',
          profile = 'GoogleStyle',
        },
      },
    },
  },
}
jdtls.start_or_attach(config)

--[[
local config = {
  cmd = { '~/.local/share/nvim/mason/bin/jdtls' },
  root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1]),
}
require('jdtls').start_or_attach(config)
--]]
