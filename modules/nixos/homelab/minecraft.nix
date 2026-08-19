{ pkgs, lib, inputs, ... }:

let
  # ===========================================================================
  # Homestead modpack
  # ===========================================================================

  modpackRaw = pkgs.fetchModrinthModpack {
    url = "https://cdn.modrinth.com/data/6HvKwSky/versions/WMsE2fOj/Homestead%201.3.7.mrpack";
    packHash = "sha256-JeT5l11PqP5Hv4HvN2wa4S73I2VRdVGVN9pjJrhwpc0=";
    side = "server";
  };

  # Remove the client-only mod that is incorrectly marked as server-compatible
  # in the published pack.
  modpack = pkgs.runCommand "homestead-server-fixed" { } ''
    mkdir -p $out
    cp -r ${modpackRaw}/. $out
    chmod -R u+w $out
    rm -f $out/mods/colorwheel_patcher*.jar
  '';

  # ===========================================================================
  # lazymc
  #
  # Homestead is Minecraft 1.20.1, so deliberately pin lazymc to 0.2.10.
  # v0.2.11 changed the supported Minecraft protocol range to 1.20.3+.
  # ===========================================================================

  lazymc = pkgs.rustPlatform.buildRustPackage {
    pname = "lazymc";
    version = "0.2.10";

    src = pkgs.fetchFromGitHub {
      owner = "timvisee";
      repo = "lazymc";
      rev = "v0.2.10";

      hash = "sha256-IObLjxuMJDjZ3M6M1DaPvmoRqAydbLKdpTQ3Vs+B9Oo=";
    };

    cargoHash = "sha256-Tx+Bof4NtVd7AlYMS6veLiT/9vBXPIRVpMecoW7SpfM=";
  };

  # ===========================================================================
  # Start the nix-minecraft service
  #
  # lazymc runs this command when a player connects while Homestead is asleep.
  # ===========================================================================

  startHomestead = pkgs.writeShellApplication {
    name = "start-homestead";

    runtimeInputs = [
      pkgs.systemd
      pkgs.coreutils
    ];

    text = ''
      set -euo pipefail

      systemctl start minecraft-server-homestead.service

      while ! systemctl is-active --quiet minecraft-server-homestead.service; do
        if systemctl is-failed --quiet minecraft-server-homestead.service; then
          echo "minecraft-server-homestead.service failed to start" >&2
          exit 1
        fi

        sleep 1
      done
    '';
  };

  rconPassword = "9babfab2034d4517a90e9f8937895ce6";

in
{
  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
  ];

  # ===========================================================================
  # Firewall
  #
  # lazymc owns the public Minecraft port.
  # Minecraft itself is only available on localhost:25566.
  # ===========================================================================

  networking.firewall.allowedTCPPorts = [
    25565
  ];

  # ===========================================================================
  # Minecraft / nix-minecraft
  # ===========================================================================

  services.minecraft-servers = {
    enable = true;
    eula = true;

    servers.homestead = {
      enable = true;

      # lazymc decides when the server starts.
      autoStart = false;

      # Do NOT expose Minecraft directly.
      openFirewall = false;

      package = pkgs.fabricServers.fabric-1_20_1.override {
        loaderVersion = "0.18.4";
      };

      symlinks = {
        mods = "${modpack}/mods";
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
        # ---------------------------------------------------------------------
        # lazymc owns :25565.
        # Minecraft itself listens only on localhost :25566.
        # ---------------------------------------------------------------------

        server-port = 25566;
        server-ip = "127.0.0.1";

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

        # ---------------------------------------------------------------------
        # RCON
        #
        # lazymc uses RCON to gracefully stop the Minecraft server after the
        # idle timeout.
        #
        # TODO: move to a proper secret-management solution (agenix, sops-nix).
        # ---------------------------------------------------------------------

        enable-rcon = true;
        "rcon.port" = 25575;
        "rcon.password" = rconPassword;
      };

      operators = {
        BadCallouts = "673efeda4d3c476a834054e6d77613b8";
      };
    };
  };

  # ===========================================================================
  # Give the lazymc service permission to start/stop the Minecraft service.
  # ===========================================================================

  security.sudo.extraRules = [
    {
      users = [ "minecraft" ];

      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl start minecraft-server-homestead.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl stop minecraft-server-homestead.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl is-active minecraft-server-homestead.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl is-failed minecraft-server-homestead.service";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # ===========================================================================
  # lazymc configuration
  # ===========================================================================

  environment.etc."lazymc/homestead.toml".text = ''
    [public]
    address = "0.0.0.0:25565"

    # Minecraft 1.20.1 protocol.
    version = "1.20.1"
    protocol = 763

    [server]
    address = "127.0.0.1:25566"

    # NixOS/systemd starts Minecraft.
    command = "${startHomestead}"

    # We explicitly use systemd to control the process, so don't have
    # lazymc freeze the Minecraft process itself.
    freeze_process = false

    wake_on_start = false
    wake_on_crash = false
    probe_on_start = false

    forge = false

    # Homestead is modded and can take a while to boot.
    start_timeout = 120

    # Allow a reasonable amount of time for shutdown.
    stop_timeout = 120

    [time]
    # Put the server to sleep after 10 minutes with nobody online.
    sleep_after = 600

    # Prevent immediately sleeping after startup.
    min_online_time = 300

    [join]
    # Hold the player while the server boots.
    #
    # Minecraft has roughly a 30-second connection timeout, so DON'T set
    # this to 120/600 despite the server itself potentially taking longer.
    methods = ["hold", "kick"]

    [join.hold]
    timeout = 29

    [join.kick]
    starting = "§aHomestead is starting...\n\n§7Please reconnect in a moment."
    stopping = "§7Homestead is going to sleep...\n\n§7Reconnect to wake it again."

    [motd]
    sleeping = "§7Homestead is sleeping\n§aJoin to wake it up!"
    starting = "§aHomestead is starting...\n§7Please wait."
    stopping = "§7Homestead is going to sleep..."
    from_server = true

    [rcon]
    enabled = true
    port = 25575
    password = "${rconPassword}"
    randomize_password = false
    send_proxy_v2 = false

    [advanced]
    rewrite_server_properties = false

    [config]
    version = "0.2.10"
  '';

  # ===========================================================================
  # lazymc systemd service
  # ===========================================================================

  systemd.services.lazymc-homestead = {
    description = "Lazy Minecraft proxy for Homestead";

    wantedBy = [
      "multi-user.target"
    ];

    after = [
      "network-online.target"
    ];

    wants = [
      "network-online.target"
    ];

    serviceConfig = {
      ExecStart =
        "${lazymc}/bin/lazymc start --config /etc/lazymc/homestead.toml";

      Restart = "always";
      RestartSec = 5;

      User = "minecraft";
      Group = "minecraft";

      NoNewPrivileges = true;
      PrivateTmp = true;

      ProtectSystem = "strict";
      ProtectHome = true;

      # lazymc itself doesn't need to write to the Minecraft directory.
      ReadOnlyPaths = [
        "/srv/minecraft/homestead"
      ];
    };
  };

  # ===========================================================================
  # Allow lazymc to manage the Minecraft service through sudo.
  # ===========================================================================

  systemd.services.lazymc-homestead.serviceConfig = {
    SupplementaryGroups = [
      "wheel"
    ];
  };

  # ===========================================================================
  # Seed the modpack config only on first run.
  #
  # After the initial copy, the live config remains mutable and isn't replaced
  # by Nix on every restart/rebuild.
  # ===========================================================================

  systemd.services."minecraft-server-homestead".preStart =
    lib.mkAfter ''
      if [ ! -d "/srv/minecraft/homestead/config" ]; then
        cp -r ${modpack}/config /srv/minecraft/homestead/config
        chmod -R u+w /srv/minecraft/homestead/config
      fi
    '';
}
