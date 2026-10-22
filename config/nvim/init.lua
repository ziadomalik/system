vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local o = vim.opt
o.number, o.relativenumber = true, true

o.mouse = 'a'
o.signcolumn = 'yes'
o.clipboard = 'unnamedplus'
o.undofile = true

o.ignorecase, o.smartcase = true, true
o.splitright, o.splitbelow = true, true

o.expandtab, o.shiftwidth, o.tabstop = true, 2, 2
o.scrolloff = 8

o.updatetime = 250
o.cursorline = true
o.winborder = 'rounded'

vim.cmd.colorscheme('lackluster-hack')
require('mini.icons').setup()
require('mini.pairs').setup()
require('mini.surround').setup()
require('mini.statusline').setup()
require('gitsigns').setup()
require('which-key').setup()
require('oil').setup({ view_options = { show_hidden = true } })

vim.api.nvim_create_autocmd('FileType', {
  callback = function(ev) pcall(vim.treesitter.start, ev.buf) end,
})

require('blink.cmp').setup({
  keymap = { preset = 'super-tab' },
  completion = { documentation = { auto_show = true } },
  signature = { enabled = true },
  sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
})

vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities()
})

vim.lsp.config('clangd', {
  cmd = {
    '--query-driver=/nix/store/*/bin/*',
    'clangd', '--background-index', '--clang-tidy',
    '--header-insertion=iwyu', '--completion-style=detailed',
  },
})

vim.lsp.config('vtsls', {
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'vue'
  },
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = { {
          name = '@vue/typescript-plugin',
          location = vim.g.nix.vue_ls,
          languages = { 'vue' },
          configNamespace = 'typescript',
        } },
      },
    },
    typescript = {
      inlayHints = {
        parameterNames = { enabled = 'literals' },
        functionLikeReturnTypes = { enabled = true },
      },
    },
  },
})

vim.lsp.config('lua_ls', {
  settings = { Lua = { diagnostics = { globals = { 'vim' } } } }
})

vim.lsp.enable({ 'clangd', 'vtsls', 'vue_ls', 'eslint', 'lua_ls', 'nixd' })

vim.diagnostic.config({
  virtual_text = true, severity_sort = true, float = { source = true }
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local map = function(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    map('gd', vim.lsp.buf.definition, 'Go to definition')
    map('gD', vim.lsp.buf.declaration, 'Go to declaration')
    if client and client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
      map('<leader>th', function()
        local on = vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
        vim.lsp.inlay_hint.enable(not on, { bufnr = ev.buf })
      end, 'Toggle inlay hints')
    end
    if client and client.name == 'clangd' then
      map('<leader>ch', '<cmd>LspClangdSwitchSourceHeader<cr>', 'Switch .h/.cpp')
    end
  end,
})

local web = { 'prettierd', 'prettier', stop_after_first = true }

require('conform').setup({
  formatters_by_ft = {
    c = { 'clang_format' },
    cpp = { 'clang_format' },
    javascript = web,
    typescript = web,
    vue = web,
    json = web,
    css = web,
    scss = web,
    html = web,
    markdown = web,
    nix = { 'nixfmt' },
  },
  format_on_save = { timeout_ms = 1000, lsp_format = 'fallback' },
})

local dap, dapui = require('dap'), require('dapui')

dapui.setup()
dap.adapters.codelldb = { type = 'executable', command = vim.g.nix.codelldb }

dap.configurations.cpp = { {
  name = 'Launch executable',
  type = 'codelldb',
  request = 'launch',
  program = function()
    return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/build/', 'file')
  end,
  cwd = "${workspaceFolder}",
  stopOnEntry = false,
} }

dap.configurations.c = dap.configurations.cpp
dap.listeners.before.launch.dapui_config = function() dapui.open() end
dap.listeners.before.attach.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

-- Keymaps

local map = vim.keymap.set
local fzf = require('fzf-lua')
local gs = require('gitsigns')

map('n', '<leader>ff', fzf.files, { desc = 'Find files' })
map('n', '<leader>fg', fzf.live_grep, { desc = 'Grep project' })
map('n', '<leader>fb', fzf.buffers, { desc = 'Open buffers' })
map('n', '<leader>fr', fzf.oldfiles, { desc = 'Recent files' })
map('n', '<leader>fs', fzf.lsp_document_symbols, { desc = 'Symbols in file' })
map('n', '<leader>fS', fzf.lsp_live_workspace_symbols)

map('n', '-', '<cmd>Oil<cr>', { desc = 'Parent directory' })
map('n', '<leader>fh', fzf.helptags, { desc = 'Search :help' })
map('n', '<leader>fd', fzf.diagnostics_workspace, { desc = 'All diagnostics' })
map('n', '<leader>cf',
  function() require('conform').format({ async = true }) end,
  { desc = 'Format' }
)
map('n', '<leader>cb',
  '<cmd>split | terminal cmake --build build<cr>',
  { desc = 'CMake build' }
)

map('n', ']h', function() gs.nav_hunk('next') end, { desc = 'Next git hunk' })
map('n', '[h', function() gs.nav_hunk('prev') end, { desc = 'Prev git hunk' })
map('n', '<leader>gp', gs.preview_hunk, { desc = 'Preview hunk' })
map('n', '<leader>gb', gs.blame_line, { desc = 'Blame line' })
map('n', '<F5>', dap.continue, { desc = 'Debug: continue' })
map('n', '<F10>', dap.step_over, { desc = 'Debug: step over' })
map('n', '<F11>', dap.step_into, { desc = 'Debug: step into' })
map('n', '<F12>', dap.step_out, { desc = 'Debug: step out' })
map('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Toggle breakpoint' })

map('n', '<Esc>', '<cmd>nohlsearch<cr>')
map('t', '<Esc><Esc>', '<C-\\><C-n>')
