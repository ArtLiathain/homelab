{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
self.submodules = true;
  };


  outputs = { nixpkgs, ... }: {
submodules = true; 
    nixosConfigurations = {
      homelab = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/homelab/configuration.nix ];
      };

      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/desktop-vm/configuration.nix ];
      };
    };
  };
}
