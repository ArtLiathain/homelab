{ config, lib, pkgs, ... }:

{
  services.radarr = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.radarr.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
