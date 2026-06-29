{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/core
    ../../modules/nixos/desktop
    ../../modules/nixos/desktop/hyprland.nix
    ../../modules/nixos/desktop/portals.nix
    ../../modules/nixos/desktop/pipewire.nix
    ../../modules/nixos/desktop/nvidia.nix
    ../../modules/nixos/desktop/zram.nix
  ];

  networking.hostName = "desktop";

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.art = import ./home.nix;
  };

  system.stateVersion = "25.11";
}
