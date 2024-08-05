-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.terminal-integration.vim-tmux-navigator" },
  { import = "astrocommunity.terminal-integration.vim-tmux-yank" },
  { import = "astrocommunity.terminal-integration.vim-tpipeline" },
  { import = "astrocommunity.search.nvim-hlslens" },
  { import = "astrocommunity.syntax.vim-cool" },
  { import = "astrocommunity.pack.angular" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.hyprlang" },
  { import = "astrocommunity.pack.full-dadbod" },
  { import = "astrocommunity.editing-support.ultimate-autopair-nvim" },
  { import = "astrocommunity.editing-support.todo-comments-nvim" },

  -- import/override with your plugins folder
}
