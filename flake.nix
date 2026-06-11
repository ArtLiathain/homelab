{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
self.submodules = true;
        dotfiles.url = "path:./dotfiles";
    dotfiles.flake = false;
  };


  outputs = { nixpkgs, dotfiles, ... }: {
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
