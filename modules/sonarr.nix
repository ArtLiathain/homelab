{ config, lib, pkgs, ... }:

{
  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.sonarr.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
