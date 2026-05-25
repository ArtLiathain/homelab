{ config, lib, pkgs, ... }:

{
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.qbittorrent.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
