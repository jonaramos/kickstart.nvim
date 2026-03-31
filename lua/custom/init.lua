-- ===========================================================
-- FILETYPE DETECTION
-- ===========================================================
vim.filetype.add {
  pattern = {
    ['.*/.config/zsh/functions/.*'] = 'zsh',
  }
}

-- ===========================================================
-- ENVIRONMENT & RIPGREP LOGIC
-- ===========================================================
local home = os.getenv 'HOME' 
if vim.fn.has 'win32' == 1 then home = os.getenv 'USERPROFILE' end

vim.env.RIPGREP_CONFIG_PATH = vim.fn.getcwd() .. '/.ripgreprc'

vim.api.nvim_create_autocmd({ 'DirChanged' }, {
  callback = function()
    local ripgrep_config = vim.fn.getcwd() .. '/.ripgreprc'
    if vim.fn.filereadable(ripgrep_config) == 1 then vim.env.RIPGREP_CONFIG_PATH = ripgrep_config end
  end,
})

-- ===========================================================
-- LINE NUMBERS & UI SETTINGS
-- ===========================================================
vim.o.number = true -- show line numbers
vim.o.relativenumber = true -- Show proportional (relative) numbers
vim.o.cursorline = true -- Highlight the current line


-- ===========================================================
-- TABS & INDENTATION
-- ===========================================================
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true


-- =======================================================================
-- WINDOW NAVIGATION & CREATION (Colemak DH / Ghostty / Cross-OS friendly)
-- =======================================================================

-- Linux/Windows: Uses Physical Control (bottom-left)
local default_maps = {
  -- MOVE: Ctrl + Alt + Arrows
  { '<C-A-Left>', '<C-w>h', 'Move focus left' },
  { '<C-A-Right>', '<C-w>l', 'Move focus right' },
  { '<C-A-Down>', '<C-w>j', 'Move focus down' },
  { '<C-A-Up>', '<C-w>k', 'Move focus up' },

  -- CREATE: Ctrl + Alt + Shift + Arrows
  { '<C-A-S-Left>', ':vsplit<CR>', 'New v-split left' },
  { '<C-A-S-Right>', ':vsplit<CR><C-w>l', 'New v-split right' },
  { '<C-A-S-Down>', ':split<CR><C-w>j', 'New split down' },
  { '<C-A-S-Up>', ':split<CR>', 'New split up' },
}

-- MacOS: Uses Physical Command
local mac_maps = {
  -- MOVE: Cmd + Alt + Arrows
  { '<D-A-Left>', '<C-w>h', 'MacOS Move Left' },
  { '<D-A-Right>', '<C-w>l', 'MacOS Move Right' },
  { '<D-A-Down>', '<C-w>j', 'MacOS Move Down' },
  { '<D-A-Up>', '<C-w>k', 'MacOS Move Up' },

  -- CREATE: Cmd + Ctrl + Arrows (Avoids Ghostty Alt+Shift Crosshair)
  { '<D-C-Left>', ':vsplit<CR>', 'MacOS New v-split left' },
  { '<D-C-Right>', ':vsplit<CR><C-w>l', 'MacOS New v-split right' },
  { '<D-C-S-Down>', ':split<CR><C-w>j', 'MacOS New split down' },
  { '<D-C-S-Up>', ':split<CR>', 'MacOS New split up' },

}

-- The logic to apply the mappings
local function setup_window_navigation(maps)
  for _, map in ipairs(maps) do
    -- Configuration options for clean UI and documentation
    local opts = {
      desc = map[3],
      silent = true,
      noremap = true,
    }

    -- Apply to Normal MOde
    vim.keymap.set('n', map[1], map[2], opts)

    -- Apply to Terminal Mode (allows you to use the arrows to "escape" a terminal split)
    -- This uses <C-\><C-n> to drop into Normal mode before executing the move
    vim.keymap.set('t', map[1], [[<C-\><C-n>]] .. map[2], opts)
  end
end

-- ============================================================================
-- PERSONAL KEYMAPS & TWEAKS
-- ============================================================================
vim.keymap.set('v', 'E', ":m '>+1<CR>gv=gv") -- Move block down
vim.keymap.set('v', 'I', ":m '<-2<CR>gv=gv") -- Move block up
vim.keymap.set('n', 'J', 'mzJ`z') -- Join lines stay in place
vim.keymap.set('n', 'n', 'nzzzv') -- Search next center
vim.keymap.set('n', 'N', 'Nzzzv') -- Search prev center
vim.keymap.set('x', '<leader>p', "'_dP") -- Past over preserve buffer
vim.keymap.set({ 'n', 'v' }, '<leader>y', "'+y") -- Yank to system clipboard
vim.keymap.set('n', '<leader>Y', "'+Y")
vim.keymap.set('n', 'Q', '<nop>') -- Disable Ex mode

-- Auto-format on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.xml', '*.java', '*.go' },
  callback = function(args)
    vim.lsp.buf.format { bufnr = args.buf, async = false }
  end,
})

-- Open the breadcrumb "picker" to jump to a different section
vim.keymap.set('n', '<leader>bq', function()
  -- Using pcall (protected call) prevents the crash if the plugin is missing
  local ok, dropbar_api = pcall(require, 'dropbar.api')
  if ok then
    dropbar_api.pick()
  else
    print 'Dropbar is not installed yet! Run :Lazy to check.'
  end
end, { desc = 'Winbar: [B]readcrumb [Q]uickpick' })


