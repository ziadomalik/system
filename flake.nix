{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.x230 = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
      ];
    };
  };
}
