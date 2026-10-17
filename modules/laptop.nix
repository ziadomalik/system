{ pkgs, ... }:
{
  services.upower.enable = true;
  services.libinput.enable = true;
  environment.systemPackages = with pkgs; [
    brightnessctl 
  ];
}
