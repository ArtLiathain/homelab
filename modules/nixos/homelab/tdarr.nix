{ lib, ... }:
{
  services.tdarr = {
    enable = true;
    server.openFirewall = true;
    nodes.main.workers = {
      transcodeGPU = 1;
      transcodeCPU = 0;
      healthcheckGPU = 0;
      healthcheckCPU = 0;
    };
  };

  users.users.tdarr.extraGroups = [ "media" "render" "video" ];

  systemd.services."tdarr-node-main".serviceConfig = {
    UMask = lib.mkForce "002";
    ReadWritePaths = [ "/data" "/opt/tdarr/cache" "/var/lib/tdarr" ];
  };

  systemd.services."tdarr-server".serviceConfig = {
    ReadWritePaths = [ "/data" "/opt/tdarr/cache" ];
  };


  systemd.tmpfiles.rules = [
    "d /opt/tdarr/cache 0750 tdarr tdarr - -"
  ];
}
