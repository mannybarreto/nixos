{
  description = "Manny's gaming NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {};
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix

        home-manager.nixosModules.home-manager 
        {
	  home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.mannybarreto = import ./home.nix;
        }
      ];
    };
  };
}
