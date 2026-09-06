{ config, pkgs, lib, ... }:

{
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "radeonsi";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.bluetooth = {
    enable = true;
  };

  networking.networkmanager.wifi.powersave = false;

  services.logind.settings.Login.HandleLidSwitch = "suspend";

  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };

  hardware.cpu.amd.updateMicrocode = true;

  # Realtek RTL8821CE - in-kernel rtw88 driver (out-of-tree rtl8821ce removed from nixpkgs 2026-07-22)
  boot.kernelParams = [ "pcie_aspm=off" ];
}
