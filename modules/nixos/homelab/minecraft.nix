{ pkgs, lib, inputs, ... }:
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers.homestead =
      let
        modpack = pkgs.fetchModrinthModpack {
          url = "https://cdn.modrinth.com/data/6HvKwSky/versions/WMsE2fOj/Homestead%201.3.7.mrpack";
          packHash = lib.fakeHash; # build once, Nix prints the real hash, paste it in
          side = "server";
        };
      in
      {
        enable = true;
        autoStart = true;
        openFirewall = true;
        package = pkgs.fabricServers.fabric-1_20_1.override {
          loaderVersion = "0.18.4";
        };

        symlinks = {
          "mods" = "${modpack}/mods";
        };

        jvmOpts = lib.concatStringsSep " " [
          "-Xms8192M"
          "-Xmx8192M"
          "-XX:+UseG1GC"
          "-XX:+ParallelRefProcEnabled"
          "-XX:MaxGCPauseMillis=200"
          "-XX:+UnlockExperimentalVMOptions"
          "-XX:+DisableExplicitGC"
          "-XX:+AlwaysPreTouch"
          "-XX:G1NewSizePercent=30"
          "-XX:G1MaxNewSizePercent=40"
          "-XX:G1HeapRegionSize=8M"
          "-XX:G1ReservePercent=20"
          "-XX:G1HeapWastePercent=5"
          "-XX:G1MixedGCCountTarget=4"
          "-XX:InitiatingHeapOccupancyPercent=15"
          "-XX:G1MixedGCLiveThresholdPercent=90"
          "-XX:G1RSetUpdatingPauseTimePercent=5"
          "-XX:SurvivorRatio=32"
          "-XX:MaxTenuringThreshold=1"
        ];
        serverProperties = {
          server-port = 25565;
          difficulty = "normal";
          gamemode = "survival";
          max-players = 10;
          motd = "Homestead — cozy survival";
          white-list = false;
          enable-command-block = true;
          view-distance = 10;
          simulation-distance = 8;
          spawn-protection = 0;
          pvp = true;
          network-compression-threshold = 256;
          max-tick-time = 60000;
        };
        operators = {
          BadCallouts = "673efeda4d3c476a834054e6d77613b8";
        };
      };
  };

  systemd.services."minecraft-server-homestead".preStart =
    let
      modpack = pkgs.fetchModrinthModpack {
        url = "https://cdn.modrinth.com/data/6HvKwSky/versions/WMsE2fOj/Homestead%201.3.7.mrpack";
        packHash = lib.fakeHash;
        side = "server";
      };
    in
    lib.mkAfter ''
      if [ ! -d "/srv/minecraft/homestead/config" ]; then
        cp -r ${modpack}/config /srv/minecraft/homestead/config
        chmod -R u+w /srv/minecraft/homestead/config
      fi
    '';
}
