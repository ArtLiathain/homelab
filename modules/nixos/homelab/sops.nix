{ config, lib, ... }:

{
  sops.defaultSopsFile = ../../../secrets/homelab.yaml;

  sops.secrets = {
    "sonarr-key" = { owner = "homepage-dashboard"; group = "homepage-dashboard"; mode = "0440"; };
    "radarr-key" = { owner = "homepage-dashboard"; group = "homepage-dashboard"; mode = "0440"; };
    "lidarr-key" = { owner = "homepage-dashboard"; group = "homepage-dashboard"; mode = "0440"; };
    "prowlarr-key" = { owner = "homepage-dashboard"; group = "homepage-dashboard"; mode = "0440"; };
    "jellyfin-key" = { owner = "homepage-dashboard"; group = "homepage-dashboard"; mode = "0440"; };
    "jellyseerr-key" = { owner = "homepage-dashboard"; group = "homepage-dashboard"; mode = "0440"; };
    "bazarr-key" = { owner = "homepage-dashboard"; group = "homepage-dashboard"; mode = "0440"; };
    "sabnzbd-key" = { owner = "homepage-dashboard"; group = "homepage-dashboard"; mode = "0440"; };
    # Seafile secrets are supplied as a single dotenv file loaded via
    # environmentFiles (see seafile.nix).
    "seafile-env" = {
      sopsFile = ../../../secrets/seafile.env;
      format = "dotenv";
    };
  };
}
