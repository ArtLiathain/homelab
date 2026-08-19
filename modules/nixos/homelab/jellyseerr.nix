{ ... }:

{
  services.seerr = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.jellyseerr.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
