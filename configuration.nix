{ config, lib, pkgs, ... }:
{
	imports = 
	[
		./hardware-configuration.nix
		./hosts/x230.nix
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
	
	services.xserver = {
		enable = true;
		xkb.layout = "us";
		displayManager.startx.enable = true;

		windowManager.xmonad = {
			enable = true;
			enableContribAndExtras = true;		
		};	
	};

	services.libinput.enable = true;
	programs.slock.enable = true;
	programs.xss-lock = { 
		enable = true; 
		lockerCommand = "/run/wrappers/bin/slock";
	};

	environment.loginShellInit = ''
		[ "$(tty)" = /dev/tty1 ] && startx
	'';

	# ___ Packages ___

	environment.systemPackages = with pkgs; [
		vim git
		alacritty dmenu
		brightnessctl xclip xset
	];

	# ___ Nix ___

	programs.direnv = { enable = true; nix-direnv.enable = true; };
	programs.nix-ld.enable = true;

	nix.settings.experimental-features = [ "nix-command" "flakes" ];
	nix.gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 14d"; };
	
	system.stateVersion = "26.05";
}
