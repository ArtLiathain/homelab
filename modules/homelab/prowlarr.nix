{ config, lib, pkgs, ... }:

{
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.prowlarr.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
