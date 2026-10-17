{ pkgs, user, ... }:
{

  imports = [
    ./git.nix
    ./shell.nix
    ./terminal.nix
  ];
  
  home.username = user;
  home.homeDirectory = "/home/${user}";

  home.packages = with pkgs; [
    dmenu  
    ranger ueberzug
    ungoogled-chromium
    keepassxc
  ];

  home.stateVersion = "26.05";
}
