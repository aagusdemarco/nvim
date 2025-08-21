local vim = vim

-- keymaps
vim.g.mapleader = ' '

local map = vim.keymap.set
map('n', '<leader>pv', vim.cmd.Ex)
map('n', '<leader>lf', vim.lsp.buf.format)
map('n', '<leader>c', '1z=')

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
  { src = 'https://github.com/prichrd/netrw.nvim' },
  { src = 'https://github.com/Saghen/blink.cmp',                version = vim.version.range('1.*') },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  { src = 'https://github.com/folke/tokyonight.nvim' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
})

require('netrw').setup({})
require('blink.cmp').setup({})

vim.cmd [[colorscheme tokyonight-night]]

-- config de LSP
vim.lsp.enable({ 'lua_ls', 'ts_ls', 'hls', 'pylsp' })

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
