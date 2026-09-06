{ config, lib, pkgs, ... }:

let
  modsDir = "/srv/terraria/data/tModLoader/Mods";
in
{
  virtualisation.oci-containers.containers.terraria = {
    image = "docker.io/jacobsmile/tmodloader1.4:v2026.08.2.1";
    autoStart = true;
    ports = [ "0.0.0.0:7777:7777" ];
    volumes = [ "/srv/terraria/data:/data" ];
    environment = {
      TMOD_AUTOSAVE_INTERVAL = "10";
      TMOD_MOTD = "Welcome!";
      TMOD_PASS = "N/A"; # open server (no join password)
      TMOD_MAXPLAYERS = "8";
      TMOD_WORLDNAME = "AW's Adventures";
      TMOD_DIFFICULTY = "1"; # Expert
      # TMOD_AUTODOWNLOAD / TMOD_ENABLEDMODS deliberately unset:
      # no Steam interaction, no auto-updates. The server enables mods
      # from enabled.json (generated below).
    };
  };

  # Generate tModLoader's enabled.json from the .tmod filenames staged in
  # the Mods folder. The internal mod name is the .tmod filename without the
  # extension (same as jacobsmile's own enable logic). Runs once before the
  # server container starts so the enabled list always matches what's on disk.
  systemd.services.terraria-enabled-json = {
    description = "Generate tModLoader enabled.json from staged mods";
    before = [ "podman-terraria.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "terraria-enabled-json" ''
        set -euo pipefail
        if [ ! -d "${modsDir}" ] || [ -e "${modsDir}/enabled.json" ]; then
          exit 0
        fi
        find "${modsDir}" -maxdepth 1 -name '*.tmod' -printf '%f\n' \
          | sed 's/\.tmod$//' \
          | sort \
          | ${pkgs.jq}/bin/jq -R . | ${pkgs.jq}/bin/jq -s . \
          > "${modsDir}/enabled.json"
        chown 1000:1000 "${modsDir}/enabled.json"
      '';
    };
  };

  # Tailscale traffic is trusted; the server is reachable only over the VPN.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  systemd.tmpfiles.rules = [
    "d /srv/terraria/data 2755 art media - -"
    "d ${modsDir} 2755 art media - -"
  ];
}
