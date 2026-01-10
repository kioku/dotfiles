-- LSP configuration overrides
return {
  -- Deno/TypeScript LSP conflict resolution
  -- Ensures only one LSP attaches: denols for Deno projects, tsserver for Node projects
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        denols = {
          root_dir = require("lspconfig").util.root_pattern("deno.json", "deno.jsonc"),
        },
        tsserver = {
          root_dir = require("lspconfig").util.root_pattern("package.json"),
          single_file_support = false,
        },
      },
      setup = {
        tsserver = function(_, opts)
          local original_on_attach = opts.on_attach
          opts.on_attach = function(client, bufnr)
            -- Check for Deno root at attachment time to avoid race condition
            local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
            if deno_root then
              client.stop()
              return
            end
            if original_on_attach then
              original_on_attach(client, bufnr)
            end
          end
        end,
      },
    },
  },
}
