{ config, lib, pkgs, ... }:

{
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.prowlarr.serviceConfig = {
    UMask = "002";
    ReadWritePaths = [ "/data" ];
  };
}
