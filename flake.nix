{

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manaer = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs"; 
    };
  };
  
  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      user = "ziad";
      mkHost = hostname: nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs user hostname; }; 
        modules = [
          ./hosts/${hostname}
          ./modules/base.nix 

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true; 
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bak";
            home-manager.extraSpecialArgs = { inherit inputs user hostname; };
            home-manager.users.${user} = import ./home;
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        x230 = mkHost "x230"; 
      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
