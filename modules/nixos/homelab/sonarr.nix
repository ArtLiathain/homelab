{ config, lib, pkgs, ... }:

{
  services.sonarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  systemd.services.sonarr.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
