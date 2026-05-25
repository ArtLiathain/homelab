{ config, lib, pkgs, ... }:

{
  services.lidarr = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.lidarr.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
