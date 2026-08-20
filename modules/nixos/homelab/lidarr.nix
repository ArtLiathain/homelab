{ ... }:

{
  services.lidarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  systemd.services.lidarr.serviceConfig = {
    UMask = "002";
    ReadWritePaths = [ "/data" ];
  };
}
