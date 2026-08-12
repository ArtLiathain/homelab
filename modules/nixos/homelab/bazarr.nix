{ config, lib, pkgs, ... }:

{
  services.bazarr = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.bazarr.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
