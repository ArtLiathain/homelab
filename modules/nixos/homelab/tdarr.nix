{ ... }:
{
  services.tdarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  systemd.services.radarr.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
