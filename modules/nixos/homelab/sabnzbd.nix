{ config, lib, pkgs, ... }:

{
  services.sabnzbd = {
    enable = true;
    openFirewall = true;
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
    ReadWritePaths = [ "/data" ];
  };
}
