{ ... }:

{
  services.seerr = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.jellyseerr.serviceConfig = {
    UMask = "002";
    ReadWritePaths = [ "/data" ];
  };
}
