{ config, lib, ... }:

{
  sops.defaultSopsFile = ../../../secrets/homelab.yaml;

  sops.secrets = {
    "sonarr-key" = {};
    "radarr-key" = {};
    "lidarr-key" = {};
    "prowlarr-key" = {};
    "jellyfin-key" = {};
    "jellyseerr-key" = {};
    "bazarr-key" = {};
    "sabnzbd-key" = {};
    # Seafile secrets are supplied as a single dotenv file loaded via
    # environmentFiles (see seafile.nix).
    "seafile-env" = {
      sopsFile = ../../../secrets/seafile.env;
      format = "dotenv";
    };
  };
}
