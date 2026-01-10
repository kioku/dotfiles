-- Lazygit integration configured for nushell
return {
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        config = {
          os = {
            editPreset = "nvim-remote",
            -- Nushell-compatible edit commands (using `;` instead of `&&`)
            edit = "nvim --server $env.NVIM --remote-send 'q'; nvim --server $env.NVIM --remote {{filename}}",
            editAtLine = "nvim --server $env.NVIM --remote-send 'q'; nvim --server $env.NVIM --remote {{filename}}; nvim --server $env.NVIM --remote-send ':{{line}}<CR>'",
          },
        },
      },
    },
  },
}
