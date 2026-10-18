{ config, lib, pkgs, ... }:
{
	imports = 
	[
		./hardware-configuration.nix
		./x230.nix
	];

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
		LC_TIME        = "en_GB.UTF-8";
		LC_PAPER       = "de_CH.UTF-8";
		LC_MONETARY    = "de_CH.UTF-8";
		LC_MEASUREMENT = "de_CH.UTF-8";
	};

	services.xkb.layout = "us";
	console.useXkbConfig = true;

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
			"networkmanager"
		];
	};

	# ___ Desktop ___

	programs.niri.enable = true;
	environment.loginShellInit = ''
		[ "$(tty)" = /dev/tty1 ] && exec niri-session
	'';

	# ___ Packages ___

	environment.systemPackages = with pkgs; [
		alacritty fuzzel waybar mako swaylock swayidle
		xwayland-satellite brightnessctl wl-clipboard
		ungoogled-chromium git neovim ripgrep fd htop openconnect zathura
	];

	# ___ Nix ___

	programs.direnv = { enable = true; nix-direnv.enable = true; };
	programs.nix-ld.enable = true;

	nix.settings.experimental-features = [ "nix-command" "flakes" ];
	nix.gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 14d"; };
	
	system.stateVersion = "26.05";
}
