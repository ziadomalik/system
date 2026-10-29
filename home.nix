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
      grep = "rg";

      rebuild = "sudo nixos-rebuild switch --flake ~/system";

      eth-up = "sudo systemctl start eth-vpn";
      eth-down = "sudo systemctl stop eth-vpn";
    };

    initExtra = ''
      config() {
        cd ~/system || return

        [ $# -eq 0 ] && { vim .; return; }

        local match
        match=$(fd --hidden --exclude .git | fzf --filter "$*" --scheme=path | head -n1)

        if [ -n "$match" ]; then
          vim "$match"
        else
          echo "config: nothing matches '$*'" >&2
        fi
      }
    '';
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
    fd
    fzf
    ripgrep

    ranger
    ueberzug

    openconnect
    telegram-desktop

    xournalpp
    inkscape
    zathura

    mpv
    ffmpeg

    ghc
    gcc
    cmake
    nodejs
    pnpm
  ];

  fonts.fontconfig.defaultFonts.monospace = [ "MonaspiceXe Nerd Font" ];

  home.stateVersion = "26.05";
}
