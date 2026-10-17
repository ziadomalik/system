{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix 
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x230

    ../../modules/desktop.nix
    ../../modules/laptop.nix
  ];

  boot.loader.system-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "26.05";
}
