{ pkgs, ... }:
{
  # ___ Boot ___

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ___ Networking ___

  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openconnect
    ];
  };

  # ___ Locale ___

  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "en_GB.UTF-8";
    LC_PAPER = "de_CH.UTF-8";
    LC_MONETARY = "de_CH.UTF-8";
    LC_MEASUREMENT = "de_CH.UTF-8";
  };

  # ___ Audio ___

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # ___ User ___

  users.users.ziad = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "camera"
      "docker"
      "networkmanager"
      "scanner"
      "lp"
    ];
  };

  # ___ Desktop ___

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "altgr-intl";
    displayManager.startx.enable = true;

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "suspend";
  };

  programs.slock.enable = true;
  programs.xss-lock = {
    enable = true;
    lockerCommand = "/run/wrappers/bin/slock";
  };

  environment.loginShellInit = ''
    		[ "$(tty)" = /dev/tty1 ] && exec startx
    	'';

  # ___ Printing ___

  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
    disabledDefaultBackends = [ "escl" ];
  };

  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  services.ipp-usb.enable = true;

  # ___ Packages ___

  environment.systemPackages = with pkgs; [
    vim
    git
    alacritty
    dmenu
    brightnessctl
    xclip
    xset
    simple-scan
  ];

  virtualisation.docker.enable = true;
  services.udisks2.enable = true;
  programs.gphoto2.enable = true;

  # ___ Nix ___

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.nix-ld.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  system.stateVersion = "26.05";
}
