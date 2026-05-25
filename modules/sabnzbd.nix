{ config, lib, pkgs, ... }:

{
  services.sabnzbd = {
    enable = true;
    openFirewall = true;
    settings.misc = {
      download_dir = "/data/usenet/incomplete";
      complete_dir = "/data/usenet/complete";
    };
  };

  systemd.services.sabnzbd.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
