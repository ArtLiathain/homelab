{ lib, ... }:
{
  # Replace tdarr-node's bundled pnpm (doesn't run on NixOS) with nixpkgs' pnpm.
  nixpkgs.overlays = [
    (final: prev: {
      tdarr = prev.tdarr.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          rm -f $out/share/tdarr-node/runtime/pnpm
          ln -s ${prev.nodePackages.pnpm}/bin/pnpm $out/share/tdarr-node/runtime/pnpm
        '';
      });
    })
  ];

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


  systemd.tmpfiles.rules = [
    "d /opt/tdarr/cache 0750 tdarr tdarr - -"
  ];
}
