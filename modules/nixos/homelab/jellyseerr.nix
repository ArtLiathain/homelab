{ ... }:

{
  services.seerr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  systemd.services.jellyseerr.serviceConfig = {
    UMask = "002";
    ReadWritePaths = [ "/data" ];
  };
}
