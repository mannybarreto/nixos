{
  description = "Manny's gaming NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      user = "mannybarreto";
    in
    {
      nixosConfigurations = {
        "battlestation" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            # Import the main host configuration
            ./hosts/battlestation/configuration.nix

            # Sops module for system-wide secrets
            sops-nix.nixosModules.sops

            # Home Manager setup
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${user} = import ./users/${user}/home.nix;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.sharedModules = [
                # Sops module for user secrets
                sops-nix.homeManagerModules.sops
              ];
            }
          ];
        };
      };

      # Standalone home-manager configuration
      homeConfigurations = {
        "${user}" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./users/${user}/home.nix
            sops-nix.homeManagerModules.sops
          ];
        };
      };
    };
}