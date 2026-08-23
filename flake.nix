{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    unmanic-nix.url = "github:psoewish/unmanic-nix";
    qylock.url = "github:Darkkal44/qylock";
  };

  outputs = { nixpkgs, home-manager, qylock, nix-minecraft, unmanic-nix, ... }@inputs: {
    nixosConfigurations = {
      homelab = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/homelab/configuration.nix
          home-manager.nixosModules.home-manager
          nix-minecraft.nixosModules.minecraft-servers
          unmanic-nix.nixosModules.default
        ];
      };

      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/desktop/configuration.nix
          home-manager.nixosModules.home-manager
          qylock.nixosModules.default
        ];
      };

      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/laptop/configuration.nix
          home-manager.nixosModules.home-manager
          qylock.nixosModules.default
        ];
      };
    };
  };
}
