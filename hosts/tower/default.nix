{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # ___ Boot ___

  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelParams = [ "transparent_hugepage=never" ];

  # ___ Hardware ___

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = false;
    nvidiaSettings = true;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };

  # ___ Mouse ___

  services.libinput.mouse.leftHanded = true;

  # ___ Virtualization ___

  virtualisation.vmware.host.enable = true;

  # ___ Networking ___

  networking.hostName = "tower";

  # ___ Tower-Specific Software ___

  programs.obs-studio = {
    enable = true;
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi
      obs-gstreamer
      obs-vkcapture
    ];
  };

  # ___ Nix-Specific ___

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
