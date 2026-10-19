{ config, pkgs, ... }:
{
	home.username = "ziad";
	home.homeDirectory = "/home/ziad";

	xdg.configFile."xmonad" = {
		source = ./config/xmonad; 
		recursive = true;
	};

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
			config  = "vim ~/system";
			rebuild = "sudo nixos-rebuild switch --flake ~/system";
		};
	};

	programs.git = {
		enable = true;
		settings.user = {
			name = "Ziad Malik";
			email = "me@ziadmalik.com";
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

	home.packages = with pkgs; [
		ranger ueberzug

		flameshot
		ungoogled-chromium openconnect

		xournalpp zathura

		mpv ffmpeg

		ghc
		gcc cmake
		nodejs pnpm
	];

	home.stateVersion = "26.05";
}
