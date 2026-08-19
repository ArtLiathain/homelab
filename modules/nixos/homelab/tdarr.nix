{ ... }:
{
  services.tdarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  systemd.services.tdarr.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
