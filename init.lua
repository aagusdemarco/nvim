local vim = vim

-- keymaps
vim.g.mapleader = ' '

local map = vim.keymap.set
map('n', '<leader>pv', vim.cmd.Ex)
map('n', '<leader>lf', vim.lsp.buf.format)
map('n', '<leader>c', '1z=')
map({ 'n', 'v' }, '<leader>y', '"+y')
map({ 'n', 'v' }, '<leader>d', '"+d')
map({ 'n', 'v' }, '<leader>p', '"+p')

-- limpiar resaltado de busqueda
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- lsp keymaps
map('n', 'gd', vim.lsp.buf.definition, { desc = 'Ir a definicion' })
map('n', 'gr', vim.lsp.buf.references, { desc = 'Ver referencias' })
map('n', 'K', vim.lsp.buf.hover, { desc = 'Hover doc' })
map('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Renombrar simbolo' })
map('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })

-- typst preview
map('n', '<leader>tp', '<cmd>TypstPreview<CR>', { desc = 'Typst Preview' })

-- num de linea
vim.opt.number = true
vim.opt.relativenumber = true

-- resaltar linea del cursor
vim.opt.cursorline = true

-- tabulacion y espacios
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- scroll y layout
vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.termguicolors = true
vim.opt.wrap = false
vim.opt.splitright = true
vim.opt.splitbelow = true

-- undo persistente
vim.opt.undofile = true

-- busqueda
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- agregar popups con feedback
vim.diagnostic.config({
  virtual_text = true,
  signals = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true
})

-- plugins
vim.pack.add({
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/nvim-telescope/telescope.nvim' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/prichrd/netrw.nvim' },
  { src = 'https://github.com/Saghen/blink.cmp',                version = vim.version.range('1.*') },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  { src = 'https://github.com/folke/tokyonight.nvim' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  { src = 'https://github.com/chomosuke/typst-preview.nvim',    version = vim.version.range('1.*') },
  { src = 'https://github.com/echasnovski/mini.pairs' },
})

require('netrw').setup({})
require('blink.cmp').setup({})
require('mini.pairs').setup({})

-- treesitter
require('nvim-treesitter').setup({
  ensure_installed = {
    'lua', 'python', 'javascript', 'typescript', 'haskell',
    'json', 'typst', 'markdown', 'markdown_inline',
  },
  highlight = { enable = true },
})

local builtin = require('telescope.builtin')
map('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
map('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
map('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
map('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- colorscheme
vim.cmd [[colorscheme tokyonight-night]]

-- capabilities para todos los LSPs (blink.cmp + snippets)
local capabilities = require('blink.cmp').get_lsp_capabilities()
vim.lsp.config('*', { capabilities = capabilities })

-- config de LSP
vim.lsp.enable({ 'lua_ls', 'eslint', 'jsonls', 'hls', 'pylsp', 'tinymist', 'ts_ls' })

-- lua-language-server
vim.lsp.config('lua_ls', {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
          path ~= vim.fn.stdpath('config')
          and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        version = 'LuaJIT',
        path = {
          'lua/?.lua',
          'lua/?/init.lua',
        },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
        }
      }
    })
  end,
  settings = {
    Lua = {}
  }
})

-- haskell-language-server
vim.lsp.config('hls', {
  filetypes = { 'haskell', 'lhaskell', 'cabal' },
})

-- python lsp
vim.lsp.config('pylsp', {
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          ignore = { 'W391' },
          maxLineLength = 100
        }
      }
    }
  }
})

-- tinymist lsp
vim.lsp.config('tinymist', {
  cmd = { 'tinymist' },
  filetypes = { 'typst' },
  settings = {}
})

-- eslint
local base_on_attach = vim.lsp.config.eslint.on_attach
vim.lsp.config('eslint', {
  on_attach = function(client, bufnr)
    if not base_on_attach then return end

    base_on_attach(client, bufnr)
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      command = 'LspEslintFixAll',
    })
  end,
})

-- jsonls
vim.lsp.config('jsonls', {})

-- activar spell para markdown y typst
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'typst' },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = 'en,es'
  end,
})
