{ ... }:
{
  services.radarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  systemd.services.radarr.serviceConfig = {
    UMask = "002";
    ReadWritePaths = [ "/data" ];
  };
}
