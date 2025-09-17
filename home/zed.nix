{ pkgs, ... }:

{
  programs.zed-editor = {
    enable = true;
    package = pkgs.unstable.zed-editor;
    extensions = [ "nix" ];
    extraPackages = with pkgs; [ nixd nixfmt-rfc-style unstable.rust-analyzer ];
    userSettings = {
      vim_mode = true;
      buffer_font_size = 14;
      buffer_font_family = "CaskaydiaCove Nerd Font";
      preferred_line_length = 120;
      format_on_save = "off";

      lsp = {
        "rust-analyzer" = {
          binary = {
            path = "${pkgs.unstable.rust-analyzer}/bin/rust-analyzer";
          };
        };
      };
    };
  };
}
