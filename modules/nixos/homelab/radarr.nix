{ lib, ... }:
{
  services.radarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  systemd.services.radarr.serviceConfig = {
    UMask = lib.mkForce "002";
    ReadWritePaths = [ "/data" ];
  };
}
