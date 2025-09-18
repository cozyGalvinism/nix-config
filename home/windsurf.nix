{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.windsurf;
    mutableExtensionsDir = true;
  };
}
