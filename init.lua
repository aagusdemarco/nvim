local vim = vim

-- keymaps
vim.g.mapleader = ' '

local map = vim.keymap.set
map('n', '<leader>pv', vim.cmd.Ex)
map('n', '<leader>lf', vim.lsp.buf.format)
map('n', '<leader>c', '1z=')
map({ 'n', 'v' }, '<leader>y', '"+y')
map({ 'n', 'v' }, '<leader>d', '"+d')

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
})

require('netrw').setup({})
require('blink.cmp').setup({})

local builtin = require('telescope.builtin')
map('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
map('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
map('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
map('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- colorscheme
vim.cmd [[colorscheme tokyonight-night]]

-- config de LSP
vim.lsp.enable({ 'lua_ls', 'esLint', 'jsonls', 'hls', 'pylsp', 'tinymist', 'ts_ls' })
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

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
vim.lsp.config["tinymist"] = {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  settings = {
  }
}

-- esLint
local base_on_attach = vim.lsp.config.eslint.on_attach
vim.lsp.config("eslint", {
  on_attach = function(client, bufnr)
    if not base_on_attach then return end

    base_on_attach(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "LspEslintFixAll",
    })
  end,
})

-- jsonls
vim.lsp.config('jsonls', {
  capabilities = capabilities,
})
