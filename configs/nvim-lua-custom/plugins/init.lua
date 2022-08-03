return {
   { "elkowar/yuck.vim", ft = "yuck", disable = 1 },
   { "ellisonleao/glow.nvim", cmd = "Glow" },
   { "lervag/vimtex" },
   { "folke/lsp-colors.nvim" },
   { "glepnir/dashboard-nvim" },
   { "f-person/git-blame.nvim" },
   { "sbdchd/neoformat" },
   { "luochen1990/rainbow" },
   { "fatih/vim-go" },
   { "uiiaoo/java-syntax.vim" },
   { "catppuccin/nvim", as = "catppuccin" }

   { 
     "neoclide/coc.nvim",
     run = "npm install",
   },

   {
    "danymat/neogen",
    config = function()
        require('neogen').setup {}
    end,
    requires = "nvim-treesitter/nvim-treesitter",
    -- Uncomment next line if you want to follow only stable versions
    -- tag = "*"
   },

   {
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
      end
   },

   {
      "windwp/nvim-ts-autotag",
      ft = { "html", "javascriptreact" },
      after = "nvim-treesitter",
      config = function()
         require("nvim-ts-autotag").setup()
      end,
   },

   {
      "jose-elias-alvarez/null-ls.nvim",
      after = "nvim-lspconfig",
      config = function()
         require("custom.plugins.null-ls").setup()
      end,
   },

   {
      "nvim-telescope/telescope-media-files.nvim",
      after = "telescope.nvim",
      config = function()
         require("telescope").setup {
            extensions = {
               media_files = {
                  filetypes = { "png", "webp", "jpg", "jpeg" },
               },
            -- fd is needed
            },
         }
         require("telescope").load_extension "media_files"
      end,
   },

   {
      "Pocco81/TrueZen.nvim",
      cmd = {
         "TZAtaraxis",
         "TZMinimalist",
         "TZFocus",
      },
      config = function()
         require "custom.plugins.truezen"
      end,
   },
}
