{ config, lib, pkgs, ... }:
let
  dataDir = "/srv/terraria/data";
  steamDir = "/srv/terraria/steamcmd";
  steamAppId = "1281930"; # tModLoader
  modpack = "default";
  packModsDir = "${dataDir}/ModPacks/${modpack}/Mods";
  tmlVersion = "2026.07.3.0";

  workshopIds = [
    "2669644269"
    "2909886416"
    "3449158983"
    "2982372319"
    "3449149200"
    "2908170107"
    "2939093580"
    "2836679312"
    "2563309347"
    "3310041861"
    "2687866031"
    "2816694149"
    "2868553455"
    "2562925043"
    "2773928114"
    "2619954303"
    "2565639705"
    "2898168528"
  ];

  downloadArgs = lib.concatMapStringsSep " " (id: "+workshop_download_item ${steamAppId} ${id}") workshopIds;

  # tModLoader branch channel the server runs (e.g. 2026.06.3.6 -> "2026.06");
  # mod builds are pinned to branches at or below this.
  targetChannel = lib.concatStringsSep "." (lib.take 2 (lib.splitString "." tmlVersion));
in
{
  virtualisation.oci-containers.containers.terraria = {
    image = "docker.io/passivelemon/terraria-docker:tmodloader-${tmlVersion}";
    autoStart = true;
    ports = [ "0.0.0.0:7777:7777" ];
    volumes = [ "${dataDir}:/opt/terraria/config/" ];
    environment = {
      MODPACK = modpack;
      WORLDNAME = "AW's Adventures";
      DIFFICULTY = "1"; # Expert
      MAXPLAYERS = "8";
      MOTD = "Welcome!";
      PUID = "1000"; # art
      PGID = "997"; # media; 999 collides with an Alpine base group
      AUTOCREATE = "2"; # Medium
      # PASSWORD deliberately unset: image default "" means no join password.
    };
  };

  # NixOS's oci-containers module runs podman with --rm by default, which
  # conflicts with podman's own --restart flag. Instead, let systemd handle
  # restarts on any exit (crash, OOM, graceful shutdown, etc.).
  systemd.services.podman-terraria.serviceConfig = {
    Restart = lib.mkForce "always";
    RestartSec = 60;
  };

  # Download mods from the Steam Workshop on the host with steamcmd, stage
  # them into ModPacks/default/Mods/ alongside a regenerated enabled.json, and
  # hand the folder to the PassiveLemon container via the bind mount. Runs
  # once before the server container starts; re-runs only if enabled.json is
  # missing (e.g. rm the marker and restart the service to update mods).
  systemd.services.terraria-modpack-sync = {
    description = "Sync tModLoader modpack from Steam Workshop";
    after = [ "systemd-tmpfiles-setup.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    before = [ "podman-terraria.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "art";
      Environment = [ "HOME=${steamDir}" ];
      TimeoutStartSec = 0;
      Restart = "on-failure";
      RestartSec = 60;
      ExecStart = pkgs.writeShellScript "terraria-modpack-sync" ''
        set -euo pipefail
        if [ -e "${packModsDir}/enabled.json" ]; then
          exit 0
        fi

        mkdir -p "${packModsDir}"

        ${pkgs.steamcmd}/bin/steamcmd \
          +force_install_dir ${steamDir} \
          +login anonymous \
          ${downloadArgs} \
          +quit

        rm -f "${packModsDir}"/*.tmod
        target=${targetChannel}
        for id in ${lib.concatStringsSep " " workshopIds}; do
          src="${steamDir}/steamapps/workshop/content/${steamAppId}/$id"
          found=0
          if [ -d "$src" ]; then
            # Workshop items store one build per tModLoader branch (directories
            # named like 2026.6). Pick the newest branch at or below the server's
            # TML channel so we never stage a mod built for a newer tModLoader;
            # fall back to the oldest branch if none qualifies.
            branch=$(find "$src" -mindepth 1 -maxdepth 1 -type d \
                -name '[0-9][0-9][0-9][0-9]\.[0-9]*' 2>/dev/null | sort -V | ${pkgs.gawk}/bin/awk -v t="$target" '
                  BEGIN { split(t, a, "."); ty=a[1]+0; tm=a[2]+0; keep="" }
                  { split($0, p, "/"); v=p[length(p)]; split(v, d, ".");
                    if (length(d) >= 2 && (d[1]+0 < ty || (d[1]+0 == ty && d[2]+0 <= tm))) keep=$0 }
                  END { print keep }')
            if [ -z "$branch" ]; then
              branch=$(find "$src" -mindepth 1 -maxdepth 1 -type d \
                  -name '[0-9][0-9][0-9][0-9]\.[0-9]*' 2>/dev/null | sort -V | head -n 1)
            fi
            if [ -n "$branch" ]; then
              tmod=$(find "$branch" -maxdepth 1 -type f -name '*.tmod' 2>/dev/null | head -n 1)
              if [ -n "$tmod" ] && [ -f "$tmod" ]; then
                cp -f "$tmod" "${packModsDir}/"
                found=1
              fi
            fi
          fi
          if [ "$found" -eq 0 ]; then
            echo "ERROR: no .tmod downloaded for workshop id $id (need TML <= ${targetChannel})" >&2
            exit 1
          fi
        done

        find "${packModsDir}" -maxdepth 1 -name '*.tmod' -printf '%f\n' \
          | sed 's/\.tmod$//' \
          | sort \
          | ${pkgs.jq}/bin/jq -R . | ${pkgs.jq}/bin/jq -s . \
          > "${packModsDir}/enabled.json"

        printf '%s\n' "${tmlVersion}" > "${packModsDir}/tmlversion.txt"

        chown -R art:media "${packModsDir}"
      '';
    };
  };

  # Tailscale traffic is trusted; the server is reachable only over the VPN.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  systemd.tmpfiles.rules = [
    "d ${dataDir} 2755 art media - -"
    "d ${steamDir} 0755 art media - -"
  ];
}
