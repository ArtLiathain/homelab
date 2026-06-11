{ config, pkgs, lib, ... }:

{
  hardware.bluetooth.enable = true;

  services.logind.lidSwitch = "suspend";

  services.power-profiles-daemon.enable = true;

  hardware.cpu.amd.updateMicrocode = true;
}
