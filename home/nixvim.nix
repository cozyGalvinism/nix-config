{ pkgs, ... }:

{
  programs.nixvim = {
    enable = true;

    nixpkgs.config.allowUnfree = true;

    opts = {
      expandtab = true;
      tabstop = 2;
      softtabstop = 2;
      shiftwidth = 2;
      smartindent = true;

      list = true;
      listchars = "tab:»·,trail:·,extends:›,precedes:‹,nbsp:␣";
    };
    autoCmd = [{
      event = [ "FileType" ];
      pattern = [ "make" ];
      command = "setlocal noexpandtab ts=4 sw=4 sts=0";
    }];

    clipboard = { providers.wl-copy.enable = true; };
    diagnostic.settings = { virtual_text = true; };

    dependencies.rust-analyzer = { enable = true; };
    dependencies.codeium = { enable = true; };

    plugins = {
      treesitter = { enable = true; };
      windsurf-nvim = {
        enable = true;
        autoLoad = true;
        settings = {
          enable_chat = true;
          virtual_text = { enabled = false; };
        };
      };
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-e>" = "cmp.mapping.close()";
        };
        settings.sources =
          [ { name = "nvim_lsp"; } { name = "path"; } { name = "buffer"; } { name = "codeium"; } ];
      };
      cmp-nvim-lsp.enable = true;
      lsp = {
        enable = true;
        inlayHints = true;
      };

      lspkind.enable = true;
      trouble.enable = true;
      web-devicons.enable = true;
      rustaceanvim.enable = true;
    };

    lsp.servers = {
      nixd = { enable = true; };
    };
  };
}
