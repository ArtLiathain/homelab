{ config, lib, pkgs, ... }:

{
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.jellyseerr.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
