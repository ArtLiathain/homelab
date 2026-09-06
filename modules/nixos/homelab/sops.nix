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

  sops.templates."homepage-env" = {
    content = ''
      HOMEPAGE_VAR_SONARR_KEY=${config.sops.placeholder."sonarr-key"}
      HOMEPAGE_VAR_RADARR_KEY=${config.sops.placeholder."radarr-key"}
      HOMEPAGE_VAR_LIDARR_KEY=${config.sops.placeholder."lidarr-key"}
      HOMEPAGE_VAR_PROWLARR_KEY=${config.sops.placeholder."prowlarr-key"}
      HOMEPAGE_VAR_JELLYFIN_KEY=${config.sops.placeholder."jellyfin-key"}
      HOMEPAGE_VAR_JELLYSEERR_KEY=${config.sops.placeholder."jellyseerr-key"}
      HOMEPAGE_VAR_BAZARR_KEY=${config.sops.placeholder."bazarr-key"}
      HOMEPAGE_VAR_SABNZBD_KEY=${config.sops.placeholder."sabnzbd-key"}
    '';
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
