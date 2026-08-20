{ config, lib, pkgs, ... }:

{
  services.prowlarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  systemd.services.prowlarr.serviceConfig = {
    UMask = "002";
    ReadWritePaths = [ "/data" ];
  };
}
