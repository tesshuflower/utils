-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
--

-- General options
vim.opt.colorcolumn = "120"
-- folding/unfolding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99

-- gt/gT to switch between tabs
lvim.keys.normal_mode["gt"] = ":BufferLineCycleNext<CR>"
lvim.keys.normal_mode["gT"] = ":BufferLineCyclePrev<CR>"

vim.diagnostic.config({virtual_text = false})

-- Terminal stuff
lvim.builtin.which_key.mappings["t"] = {
  name = "+Terminal",
  f = { "<cmd>ToggleTerm<cr>", "Floating terminal" },
  v = { "<cmd>2ToggleTerm size=20 direction=vertical<cr>", "Split vertical" },
  h = { "<cmd>2ToggleTerm size=20 direction=horizontal<cr>", "Split horizontal" },
}
-- Markdown Preview
lvim.builtin.which_key.mappings["m"] = {
  name = "+MarkdownPreview",
  p = { "<cmd>MarkdownPreview<cr>", "MarkdownPreview" },
  s = { "<cmd>MarkdownPreviewStop<cr>", "MarkdownPreviewStop" },
  t = { "<cmd>MarkdownPreviewToggle<cr>", "MarkdownPreviewToggle" },
}

-- Add minimap to menu
lvim.builtin.which_key.mappings["M"] = {
  name = "+Minimap",
  t = { "<cmd>MinimapToggle<cr>", "MinimapToggle" },
  m = { "<cmd>Minimap<cr>", "Minimap" },
  c = { "<cmd>MinimapClose<cr>", "MinimapClose" },
  r = { "<cmd>MinimapRefresh<cr>", "MinimapRefresh" },
}

-- Add diffview to git menu
lvim.builtin.which_key.mappings["gD"] = {
  name = "+Diffview",
  d = { "<cmd>DiffviewOpen<cr>", "DiffviewOpen" },
  m = { "<cmd>DiffviewOpen upstream/main<cr>", "DiffviewOpen upstream/main" },
  c = { "<cmd>DiffviewClose<cr>", "DiffviewClose" },
  r = { "<cmd>DiffviewRefresh<cr>", "DiffviewRefresh" },
}

-- nvim tree customizations
lvim.builtin.nvimtree.setup.view = {
  adaptive_size = true,
}

-- disable autopairs
lvim.builtin.autopairs.active = false



-- This config.lua originally taken from: https://github.com/LunarVim/starter.lvim/blob/go-ide/config.lua
------------------------
-- Treesitter
------------------------
lvim.builtin.treesitter.ensure_installed = {
  "go",
  "gomod",
}


------------------------
-- Plugins
------------------------
lvim.plugins = {
  "olexsmir/gopher.nvim",
  "leoluz/nvim-dap-go",
  {
    "Tsuzat/NeoSolarized.nvim",
      lazy = false, -- make sure we load this during startup if it is your main colorscheme
      priority = 1000, -- make sure to load this before all the other start plugins
      config = function()
        vim.cmd [[ colorscheme NeoSolarized ]]
      end
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },
  "sindrets/diffview.nvim",
  {
    "folke/todo-comments.nvim",
    event = "BufRead",
    config = function()
      require("todo-comments").setup()
    end,
  },
  {
    'wfxr/minimap.vim',
    build = "cargo install --locked code-minimap",
    -- cmd = {"Minimap", "MinimapClose", "MinimapToggle", "MinimapRefresh", "MinimapUpdateHighlight"},
    init = function ()
      vim.cmd ("let g:minimap_width = 10")
      vim.cmd ("let g:minimap_auto_start = 1")
      vim.cmd ("let g:minimap_auto_start_win_enter = 1")
    end,
  },
}

------------------------
-- Color Scheme
------------------------
lvim.colorscheme = "NeoSolarized"



------------------------
-- Formatting
------------------------
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "goimports", filetypes = { "go" } },
}
--formatters.setup {
--  { command = "goimports", filetypes = { "go" } },
--  { command = "gofumpt", filetypes = { "go" } },
--}


lvim.format_on_save = {
  enabled = true,
  pattern = { "*.go" },
  timeout = 5000
}

------------------------
-- Dap
------------------------
local dap_ok, dapgo = pcall(require, "dap-go")
if not dap_ok then
  return
end

dapgo.setup()

------------------------
-- LSP
------------------------
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "gopls" })

local lsp_manager = require "lvim.lsp.manager"
lsp_manager.setup("golangci_lint_ls", {
  on_init = require("lvim.lsp").common_on_init,
  capabilities = require("lvim.lsp").common_capabilities(),
})

lsp_manager.setup("gopls", {
  on_attach = function(client, bufnr)
    require("lvim.lsp").common_on_attach(client, bufnr)
    local _, _ = pcall(vim.lsp.codelens.refresh)
    local map = function(mode, lhs, rhs, desc)
      if desc then
        desc = desc
      end

      vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = bufnr, noremap = true })
    end
    map("n", "<leader>Ci", "<cmd>GoInstallDeps<Cr>", "Install Go Dependencies")
    map("n", "<leader>Ct", "<cmd>GoMod tidy<cr>", "Tidy")
    map("n", "<leader>Ca", "<cmd>GoTestAdd<Cr>", "Add Test")
    map("n", "<leader>CA", "<cmd>GoTestsAll<Cr>", "Add All Tests")
    map("n", "<leader>Ce", "<cmd>GoTestsExp<Cr>", "Add Exported Tests")
    map("n", "<leader>Cg", "<cmd>GoGenerate<Cr>", "Go Generate")
    map("n", "<leader>Cf", "<cmd>GoGenerate %<Cr>", "Go Generate File")
    map("n", "<leader>Cc", "<cmd>GoCmt<Cr>", "Generate Comment")
    map("n", "<leader>DT", "<cmd>lua require('dap-go').debug_test()<cr>", "Debug Test")
  end,
  on_init = require("lvim.lsp").common_on_init,
  capabilities = require("lvim.lsp").common_capabilities(),
  settings = {
    gopls = {
      usePlaceholders = true,
      gofumpt = true,
      codelenses = {
        generate = false,
        gc_details = true,
        test = true,
        tidy = true,
      },
    },
  },
})

lsp_manager.setup("marksman")

local status_ok, gopher = pcall(require, "gopher")
if not status_ok then
  return
end

gopher.setup {
  commands = {
    go = "go",
    gomodifytags = "gomodifytags",
    gotests = "gotests",
    impl = "impl",
    iferr = "iferr",
  },
}
