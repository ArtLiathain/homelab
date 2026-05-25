{ config, lib, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.jellyfin.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
