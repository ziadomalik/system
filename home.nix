{ pkgs, ... }:
{
  imports = [
    ./flakes/browser.nix
  ];

  home.username = "ziad";
  home.homeDirectory = "/home/ziad";

  xdg.configFile."xmonad" = {
    source = ./config/xmonad;
    recursive = true;
  };

  home.file.".xinitrc".text = ''
    exec xmonad
  '';

  xdg.configFile."chromium" = {
    source = ./config/chromium;
    recursive = true;
  };

  xdg.configFile."alacritty" = {
    source = ./config/alacritty;
    recursive = true;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      r = "ranger";
      cls = "clear";
      grep = "ripgrep";

      config = "vim ~/system";
      rebuild = "sudo nixos-rebuild switch --flake ~/system";

      eth-up = "sudo systemctl start eth-vpn";
      eth-down = "sudo systemctl stop eth-vpn";
    };
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Ziad Malik";
      email = "zmalik@ethz.ch";
    };
  };

  programs.ranger = {
    enable = true;
    settings = {
      preview_images = true;
      show_hidden = true;
    };
    extraConfig = ''
      			map gh cd ~ 
      			set preview_images_method ueberzug
      		'';
  };

  programs.opencode = {
    enable = true;
    extraPackages = with pkgs; [
      ripgrep
      nodejs
      uv
    ];
  };

  services.flameshot.enable = true;

  home.packages = with pkgs; [
    keepassxc
    ripgrep

    ranger
    ueberzug

    openconnect

    xournalpp
    zathura

    mpv
    ffmpeg

    ghc
    gcc
    cmake
    nodejs
    pnpm
  ];

  home.stateVersion = "26.05";
}
