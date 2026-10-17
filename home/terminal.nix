{ pkgs, ... }:
{
  home.packages = [ pkgs.alacritty ];
  xdg.configFile."alacritty/alacritty.toml".source = ./dotfiles/alacritty.toml;
}
