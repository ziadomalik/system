{ config, pkgs, ... }:
{

  # ___ Boot ___

  boot.kernelModules = [
    "acpi_call"
    "phc-intel"
  ];
  boot.extraModulePackages = [
    config.boot.kernelPackages.acpi_call
  ];

  # ___ Hardware ___

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-vaapi-driver ];
  };

  # ___ Trackpad ___

  environment.systemPackages = with pkgs; [
    xf86inputsynaptics
  ];

  services.libinput.enable = false;
  hardware.trackpoint.enable = true;

  services.xserver.synaptics = {
    enable = true;
    accelFactor = "0.4";
    horizEdgeScroll = true;
    palmDetect = true;
    tapButtons = true;
    vertTwoFingerScroll = true;
    vertEdgeScroll = true;
    buttonsMap = [
      1
      3
      2
    ];
    fingersMap = [
      1
      2
      3
    ];
  };

  # ___ Power ___

  powerManagement.enable = true;

  services.tlp.enable = true;
  services.fstrim.enable = true;
  services.upower.enable = true;
  services.thermald.enable = true;

  # ___ Networking ___

  networking.hostName = "x230";

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [
      "/etc/nixos/secrets/eduroam.env"
    ];

    profiles.eduroam = {
      connection = {
        id = "eduroam";
        type = "wifi";
      };
      wifi = {
        ssid = "eduroam";
        mode = "infrastructure";
      };
      wifi-security = {
        key-mgmt = "wpa-eap";
      };
      "802-1x" = {
        eap = "peap;";
        phase2-auth = "mschapv2";
        identity = "$ETH_USER@staff-net.ethz.ch";
        password = "$ETH_WIFI_PASSWORD";
      };

      ipv4.method = "auto";
      ipv6.method = "auto";
    };
  };
}
