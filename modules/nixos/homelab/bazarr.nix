{ config, lib, pkgs, ... }:

{
  services.bazarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  systemd.services.bazarr.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
