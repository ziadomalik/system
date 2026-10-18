{ config, pkgs, ... }:
{
	home.username = "ziad";
	home.homeDirectory = "/home/ziad";

	xdg.configFile."xmonad" = {
		source = ./config/xmonad; 
		recursive = true;
	};

	programs.bash = {
		enable = true;
		enableCompletion = true;
		shellAliases = {
			r = "ranger";
			config  = "vim ~/system";
			rebuild = "sudo nixos-rebuild switch --flake ~/system";
		};
	};

	home.packages = with pkgs; [
		ranger
		ungoogled-chromium
	];

	home.stateVersion = "26.05";
}
