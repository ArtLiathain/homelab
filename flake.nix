{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }: {
    nixosConfigurations = {
      homelab = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/homelab/configuration.nix ];
      };
      desktop-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/desktop-vm/configuration.nix ];
      };
    };
  };
}
