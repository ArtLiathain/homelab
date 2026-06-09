{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/core
    ../../modules/desktop
  ];

  networking.hostName = "desktop-vm";

  system.stateVersion = "25.11";
}
