{ config, pkgs, ... }:
{

	# ___ Boot ___

	boot.kernelModules = [ "acpi_call" ];
	boot.extraModulePackages = 
	[ 
		config.boot.kernelPackages.acpi_call 
	];

	# ___ Hardware ___

	hardware.cpu.intel.updateMicrocode = true;
	hardware.enableRedistributableFirmware = true;

	hardware.graphics = {
		enable = true;
		extraPackages = [ pkgs.intel-vaapi-driver ];
	};

	# ___ Power ___

	services.tlp = {
		enable = true;
		settings = {
			CPU_SCALING_GOVERNOR_ON_AC = "powersave";
			CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
			CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
			CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
			CPU_BOOST_ON_BAT = 0;
			
			START_CHARGE_THRESH_BAT0 = 75;
			STOP_CHARGE_THRESH_BAT0 = 85;
		};
	};
	services.power-profiles.daemon-enable = false;
	services.thermald.enable = true;
	services.fstrim.enable = true;

	# ___ Networking ___

	networking.hostname = "x230";
}
