outputs = inputs@{ nixpkgs, home-manager, ... }:
let
  mkHost = hostModule: nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      hostModule
      ./configuration.nix

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.users.ziad = import ./home.nix;
      }

      ./flakes/eth
      ./flakes/vim.nix
    ];
  };
in
{
  nixosConfigurations.x230  = mkHost ./hosts/x230;
  nixosConfigurations.tower = mkHost ./hosts/tower;
};
