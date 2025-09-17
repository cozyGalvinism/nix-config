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

    dependencies.rust-analyzer = { enable = true; };
    dependencies.codeium = { enable = true; };

    plugins = {
      treesitter = { enable = true; };
      windsurf-nvim = {
        enable = true;
        autoLoad = true;
        settings = {
          enable_chat = true;
          virtual_text = { enabled = true; };
        };
      };
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources =
          [ { name = "nvim_lsp"; } { name = "path"; } { name = "buffer"; } ];
      };

      lspkind.enable = true;
      trouble.enable = true;
      web-devicons.enable = true;
    };

    lsp.servers = {
      nixd = { enable = true; };
      rust_analyzer = {
        enable = true;
        package = pkgs.unstable.rust-analyzer;
        settings = { "rust-analyzer" = { cargo.allFeatures = true; }; };
      };
    };
  };
}
