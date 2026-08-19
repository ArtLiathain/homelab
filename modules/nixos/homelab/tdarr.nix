{ ... }:
{
  services.tdarr = {
    enable = true;
    group = "media";
  };

  systemd.services.tdarr.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
