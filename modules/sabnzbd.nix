{ config, lib, pkgs, ... }:

{
  services.sabnzbd = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.sabnzbd.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
