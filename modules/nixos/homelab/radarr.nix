{ config, lib, pkgs, ... }:

{
  services.radarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  systemd.services.radarr.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
