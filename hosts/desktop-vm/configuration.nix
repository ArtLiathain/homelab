{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/core
    ../../modules/desktop
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/pipewire.nix
    ../../modules/desktop/nvidia.nix
    ../../modules/desktop/zram.nix
  ];

  networking.hostName = "desktop-vm";

  system.stateVersion = "25.11";
}
