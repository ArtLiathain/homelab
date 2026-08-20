{ config, lib, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  systemd.services.jellyfin.serviceConfig = {
    UMask = "002";
    ReadWritePaths = [ "/data" ];
  };
}
