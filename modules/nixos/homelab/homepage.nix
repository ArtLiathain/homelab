{ config, lib, pkgs, ... }:

{
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    listenPort = 8090; # 8082 conflicts with the Seafile container

    allowedHosts = "0.0.0.0:8090,homelab:8090,100.99.146.99:8090,localhost:8090,127.0.0.1:8090";

    settings = {
      title = "Homelab";
      theme = "dark";
      color = "slate";
      iconStyle = "theme";
      statusStyle = "dot";
      cardBlur = "sm";
      headerStyle = "boxedWidgets";
      showStats = false;
      target = "_blank";
      layout = {
        Media = { style = "row"; columns = 4; };
        Downloads = { style = "row"; columns = 2; };
        "Files & Photos" = { style = "row"; columns = 2; };
        Games = { style = "row"; columns = 2; };
      };
    };

    widgets = [
      { search = { provider = "duckduckgo"; target = "_blank"; }; }
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/data/media";
          uptime = true;
          units = "metric";
        };
      }
      {
        datetime = {
          text_size = "xl";
          format = { dateStyle = "full"; timeStyle = "short"; };
        };
      }
    ];

    services = [
      {
        Media = [
          { Sonarr = {
              icon = "sh-sonarr";
              href = "http://100.99.146.99:8989";
              description = "TV";
              widget = { type = "sonarr"; url = "http://localhost:8989"; key = config.sops.secrets."sonarr-key".path; enableQueue = true; };
            }; }
          { Radarr = {
              icon = "sh-radarr";
              href = "http://100.99.146.99:7878";
              description = "Movies";
              widget = { type = "radarr"; url = "http://localhost:7878"; key = config.sops.secrets."radarr-key".path; };
            }; }
          { Lidarr = {
              icon = "sh-lidarr";
              href = "http://100.99.146.99:8686";
              description = "Music";
              widget = { type = "lidarr"; url = "http://localhost:8686"; key = config.sops.secrets."lidarr-key".path; };
            }; }
          { Prowlarr = {
              icon = "sh-prowlarr";
              href = "http://100.99.146.99:9696";
              description = "Indexers";
              widget = { type = "prowlarr"; url = "http://localhost:9696"; key = config.sops.secrets."prowlarr-key".path; };
            }; }
          { Jellyfin = {
              icon = "sh-jellyfin";
              href = "http://100.99.146.99:8096";
              description = "Media server";
              widget = { type = "jellyfin"; url = "http://localhost:8096"; key = config.sops.secrets."jellyfin-key".path; version = 1; enableBlocks = true; enableNowPlaying = true; }; # bump version = 2 when Jellyfin >= 12.x lands in nixpkgs
            }; }
          { Jellyseerr = {
              icon = "sh-jellyseerr";
              href = "http://100.99.146.99:5055";
              description = "Requests";
              widget = { type = "seerr"; url = "http://localhost:5055"; key = config.sops.secrets."jellyseerr-key".path; };
            }; }
          { Bazarr = {
              icon = "sh-bazarr";
              href = "http://100.99.146.99:6767";
              description = "Subtitles";
              widget = { type = "bazarr"; url = "http://localhost:6767"; key = config.sops.secrets."bazarr-key".path; };
            }; }
        ];
      }
      {
        Downloads = [
          { SABnzbd = {
              icon = "sh-sabnzbd";
              href = "http://100.99.146.99:8081";
              description = "Usenet";
              widget = { type = "sabnzbd"; url = "http://localhost:8081"; key = config.sops.secrets."sabnzbd-key".path; };
            }; }
          { TDarr = {
              icon = "sh-tdarr";
              href = "http://100.99.146.99:8266";
              description = "Transcoding";
              widget = { type = "tdarr"; url = "http://localhost:8266"; }; # key optional
            }; }
        ];
      }
      {
        "Files & Photos" = [
          { Immich = { icon = "sh-immich"; href = "http://100.99.146.99:2283"; description = "Photos"; }; }
          { Seafile = { icon = "sh-seafile"; href = "http://100.99.146.99:8082"; description = "Files & sync"; }; }
        ];
      }
      {
        Games = [
          { Minecraft = {
              icon = "sh-minecraft";
              description = "Homestead (1.20.1)";
              widget = { type = "minecraft"; url = "udp://127.0.0.1:25565"; }; # no href: UDP game server
            }; }
        ];
      }
    ];

    bookmarks = [
      {
        Admin = [
          { Github = [ { abbr = "GH"; href = "https://github.com"; } ]; }
          { "Homepage Docs" = [ { abbr = "HP"; href = "https://gethomepage.dev"; } ]; }
          { Tailscale = [ { abbr = "TS"; href = "https://login.tailscale.com/admin/machines"; } ]; }
        ];
      }
    ];
  };
}