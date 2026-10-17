{ pkgs, ... }:
{
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = ./xmonad.hs;
    };
  };

  services.xserver.displayManager.lightdm.enable = true;
  services.displayManager.defaultSession = "none+xmonad";

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; 
    alsa.enable = true;
    pulse.enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono 
  ];
}
