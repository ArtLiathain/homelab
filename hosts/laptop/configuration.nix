{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/core
    ../../modules/desktop
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/pipewire.nix
    ../../modules/desktop/zram.nix
    ../../modules/laptop
  ];

  networking.hostName = "laptop";

  system.stateVersion = "25.11";
}
