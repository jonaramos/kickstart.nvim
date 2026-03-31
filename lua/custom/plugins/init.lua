-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
-- require 'custom.plugins.csharp.sort_csharp'
--
---@module 'lazy'
---@type LazySpec
return {
  -- 0. Theme
  {
    'folke/tokyonight.nvim',
    lazy = false, -- IMPORTANT: Must load on startup
    priority = 1000, -- IMPORTANT: Must load before everything else
    config = function()
      require('tokyonight').setup {
        style = 'night', -- You can use 'storm', 'moon', or 'night'
        styles = {
          comments = { italic = false }, -- Your previous preference
        },
      }
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },
  -- 1. Simple Utility Plugins
  { 'ThePrimeagen/vim-be-good' },
  { 'sindrets/diffview.nvim' },
  { 'AndrewRadev/linediff.vim' },
  { 'github/copilot.vim' },

  -- 2. Oil (File Explorer)
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup {
        default_file_explorer = true,
        view_options = { show_hidden = true },
      }
      -- Move the keymap here so it's tied to the plugin
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
    end,
  },

  -- 3. Bookmarks
  {
    'tomasky/bookmarks.nvim',
    event = 'VimEnter',
    config = function()
      require('bookmarks').setup {
        save_file = vim.fn.expand '$HOME/.bookmarks',
        keywords = {
          ['@t'] = '☑️ ',
          ['@w'] = '⚠️ ',
          ['@f'] = '⛏ ',
          ['@n'] = ' ',
        },
        on_attach = function(bufnr)
          local bm = require 'bookmarks'
          local map = vim.keymap.set
          map('n', 'mm', bm.bookmark_toggle)
          map('n', 'mi', bm.bookmark_ann)
          map('n', 'mc', bm.bookmark_clean)
          map('n', 'mn', bm.bookmark_next)
          map('n', 'mp', bm.bookmark_prev)
          map('n', 'ml', bm.bookmark_list)
          map('n', 'mx', bm.bookmark_clear_all)
        end,
      }
    end,
  },

  -- 4. TypeScript Tools (Specifically added by you)
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {},
  },

  -- 5. Easy Dotnet (The big one)
  {
    'GustavEikaas/easy-dotnet.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    config = function()
      local dotnet = require 'easy-dotnet'

      local function get_secret_path(secret_guid)
        local home_dir = vim.fn.expand '~'
        if require('easy-dotnet.extensions').isWindows() then
          return home_dir .. '\\AppData\\Roaming\\Microsoft\\UserSecrets\\' .. secret_guid .. '\\secrets.json'
        end
        return home_dir .. '/.microsoft/usersecrets/' .. secret_guid .. '/secrets.json'
      end

      dotnet.setup {
        test_runner = {
          viewmode = 'float',
          enable_buffer_test_execution = true,
          noBuild = true,
          noRestore = true,
          mappings = {
            run_test_from_buffer = { lhs = '<leader>r', desc = 'run test from buffer' },
            filter_failed_tests = { lhs = '<leader>fe', desc = 'filter failed tests' },
            debug_test = { lhs = '<leader>d', desc = 'debug test' },
            run_all = { lhs = '<leader>R', desc = 'run all tests' },
            close = { lhs = 'q', desc = 'close testrunner' },
          },
        },
        terminal = function(path, action, args)
          -- (Your terminal function logic from init.lua goes here)
        end,
        secrets = { path = get_secret_path },
        picker = 'telescope',
      }

      vim.api.nvim_create_user_command('Secrets', function() dotnet.secrets() end, {})
      vim.keymap.set('n', '<C-p>', function() dotnet.run_project() end)
    end,
  },
  -- 6. Dropbar
  {
    'Bekaboo/dropbar.nvim',
    -- If you have a newer Neovim (0.10+), this works best
    event = 'BufReadPost',
    dependencies = {
      'nvim-tree/nvim-web-devicons', -- For file and language icons
      'nvim-telescope/telescope-fzf-native.nvim', -- Optional: for better filtering
    },
    config = function()
      -- This initializes the plugin with default settings
      require('dropbar').setup()
    end,
  },
}
