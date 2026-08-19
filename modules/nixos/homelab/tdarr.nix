{ ... }:
{
  services.tdarr = {
    enable = true;
    group = "media";
    nodes."MyNixNode" = {
      enable = true;
      type = "mapped"; # Keeps files aligned via shared paths

      # Point this to your Tdarr Server IP/Port
      serverURL = "192.168.1.50:8266";
    };
  };

  systemd.services.tdarr.serviceConfig = {
    ReadWritePaths = [ "/data" ];
  };
}
