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
    mode = "0400";
    restartUnits = [ "homepage-dashboard.service" ];
  };
}
