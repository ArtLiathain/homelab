{ config, lib, pkgs, ... }:

{
  services.bazarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  systemd.services.bazarr.serviceConfig = {
    UMask = "002";
    ProtectSystem = "full";
    ReadWritePaths = [ "/data" ];
  };
}
