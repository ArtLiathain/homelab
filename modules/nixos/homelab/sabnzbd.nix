{ config, lib, pkgs, ... }:

{
  services.sabnzbd = {
    enable = true;
    openFirewall = true;
    group = "media";
    settings = {
      misc = {
        host = "0.0.0.0";
        port = 8081;
        # SABnzbd often blocks external access by default unless host checking is managed or disabled
        host_whitelist = "*,";
      };
    };
  };

  systemd.services.sabnzbd.serviceConfig = {
    UMask = "002";
    ReadWritePaths = [ "/data" ];
  };
}
