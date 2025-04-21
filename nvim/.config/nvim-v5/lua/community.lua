-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.angular" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.full-dadbod" }, -- DB ui and stuff
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },
  { import = "astrocommunity.note-taking.global-note-nvim" },
  { import = "astrocommunity.editing-support.ultimate-autopair-nvim" },
  { import = "astrocommunity.editing-support.todo-comments-nvim" },
  { import = "astrocommunity.motion.harpoon" },
  { import = "astrocommunity.motion.mini-surround" },
  { import = "astrocommunity.motion.mini-move" },
  { import = "astrocommunity.motion.nvim-spider" },
  { import = "astrocommunity.search.nvim-hlslens" },
  { import = "astrocommunity.syntax.vim-cool" },
  -- import/override with your plugins folder
}
