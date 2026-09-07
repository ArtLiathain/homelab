{ config, lib, pkgs, ... }:
let
  modsDir = "/srv/terraria/data/tModLoader/Mods";
in
{
  virtualisation.oci-containers.containers.terraria = {
    image = "docker.io/jacobsmile/tmodloader1.4:v2026.08.2.1";
    autoStart = true;
    extraOptions = [ "--restart=unless-stopped" ];
    ports = [ "0.0.0.0:7777:7777" ];
    volumes = [ "/srv/terraria/data:/data" ];
    environment = {
      DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1";
      TMOD_AUTOSAVE_INTERVAL = "10";
      TMOD_MOTD = "Welcome!";
      TMOD_PASS = "N/A";
      TMOD_MAXPLAYERS = "8";
      TMOD_WORLDNAME = "AW's Adventures";
      TMOD_DIFFICULTY = "1";
    };
  };

  systemd.services.terraria-enabled-json = {
    description = "Generate tModLoader enabled.json from staged mods";
    after = [ "systemd-tmpfiles-setup.service" ];
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
        chown art:media "${modsDir}/enabled.json"
      '';
    };
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  systemd.tmpfiles.rules = [
    "d /srv/terraria/data 2755 art media - -"
    "d ${modsDir} 2755 art media - -"
  ];
}
