{ config, pkgs, ... }:
{
  home.username = "ziad";
  home.homeDirectory = "/home/ziad";

  xdg.configFile."xmonad" = {
    source = ./config/xmonad; 
    recursive = true;
  };
  
  programs.home-manager.enable = true;

  home.stateVersion = "26.05";
}
