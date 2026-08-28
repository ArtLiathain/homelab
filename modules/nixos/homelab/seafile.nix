# A base NixOS module for running Seafile (official seafile-mc image) under
# rootless Podman, orchestrated declaratively via oci-containers.
#
# Import this from your configuration.nix, e.g.:
#   imports = [ ./seafile.nix ];
#
# Architecture recap (see conversation for full detail):
#   - seafile   : the seafile-mc image bundles seaf-server (storage engine)
#                 + seahub (web UI/API) + ccnet (auth/RPC glue) as one process group
#   - mariadb   : holds metadata (users, libraries, permissions, share links)
#   - redis     : caching layer for seahub sessions/notifications
#   - actual file chunk data lives on disk, bind-mounted in from the host

{ config, pkgs, ... }:

{
  virtualisation = {
    # Enables the `containers` package set and /etc/containers config
    # (registries, storage.conf, etc.) that Podman relies on.
    containers.enable = true;

    podman = {
      enable = true;

      # We're not aliasing `docker` -> `podman` or exposing a Docker-compatible
      # socket. Nothing on this box expects /var/run/docker.sock, so leave it off.
      dockerCompat = false;

      # Podman needs a network backend to give containers their own network
      # namespace and let them resolve each other by container name (used
      # below via dependsOn + shared network).
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers = {
      # Tell the oci-containers module to generate Podman-flavored systemd
      # units instead of Docker's.
      backend = "podman";

      containers = {

        memcached = {
          image = "docker.io/library/memcached:1.6.29"; # pin explicitly
          autoStart = true;
          # seafile-mc's default LOCATION is 'memcached:11211' — no port
          # mapping needed, just resolvable by name on the shared network.
        };

        # ---------------------------------------------------------------
        # MariaDB — metadata store
        # ---------------------------------------------------------------
        mariadb = {
          image = "mariadb:11.4"; # pin explicitly; bump deliberately via Renovate
          autoStart = true;

          environment = {
            MYSQL_ROOT_PASSWORD = "CHANGE_ME_root"; # see note on secrets below
            MYSQL_LOG_CONSOLE = "true";
          };

          volumes = [
            "/var/lib/seafile/mariadb:/var/lib/mysql"
          ];

          # Not exposing a host port — only seafile/seahub containers on the
          # same Podman network need to reach this, nothing on the host does.
        };

        # ---------------------------------------------------------------
        # Redis — session/notification cache for seahub
        # ---------------------------------------------------------------
        redis = {
          image = "redis:7.4-alpine"; # pin explicitly
          autoStart = true;

          volumes = [
            "/var/lib/seafile/redis:/data"
          ];
        };

        # ---------------------------------------------------------------
        # Seafile — seaf-server + seahub + ccnet, bundled
        # ---------------------------------------------------------------
        seafile = {
          image = "seafileltd/seafile-mc:12.0.7"; # pin explicitly, not :latest
          autoStart = true;

          # Only bind to localhost — put a reverse proxy (nginx/caddy) in
          # front of this for TLS/public access rather than exposing 8082
          # directly.
          ports = [
            "0.0.0.0:8082:80"
          ];

          # /shared is where seafile-mc expects to keep everything it owns
          # that isn't in the DB: uploaded file chunks, logs, generated conf.
          volumes = [
            "/var/lib/seafile/data:/shared"
          ];

          environment = {
            DB_HOST = "mariadb"; # resolved via Podman's container DNS
            DB_ROOT_PASSWD = "CHANGE_ME_root"; # must match mariadb's root pw
            REDIS_HOST = "redis";
            REDIS_PORT = "6379";
            CACHE_PROVIDER = "redis";

            TIME_ZONE = "Etc/UTC";
            SEAFILE_ADMIN_EMAIL = "homelab";
            SEAFILE_ADMIN_PASSWORD = "CHANGE_ME_admin"; # only used on first init
            JWT_PRIVATE_KEY = "8ee4e99282a6fca814ae7e8d37b82f4a0baa16e03bca576af9091f080606e41b";

            # SEAFILE_SERVER_HOSTNAME should match whatever you'll reverse
            # proxy this behind, e.g. seafile.example.com
            SEAFILE_SERVER_HOSTNAME = "0.0.0.0";
          };

          dependsOn = [
            "mariadb"
            "redis"
          ];

          # Belt-and-suspenders: dependsOn generates systemd After=/Requires=
          # ordering, but doesn't guarantee mariadb has finished initializing
          # (vs just started) before seafile tries to connect. If you hit
          # startup races on first boot, check:
          #   journalctl -u podman-seafile -f
          # and consider adding a healthcheck/retry wrapper if needed.
        };
      };
    };
  };

  # Make sure the host directories these containers bind-mount actually
  # exist with sane ownership before the containers try to start.
  # Tailscale traffic is trusted so seafile is reachable over the VPN without
  # extra firewall holes.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  systemd.tmpfiles.rules = [
    "d /var/lib/seafile/data 0750 root root -"
    "d /var/lib/seafile/mariadb 0750 root root -"
    "d /var/lib/seafile/redis 0750 root root -"
  ];

  # -----------------------------------------------------------------------
  # NOTE ON SECRETS
  # -----------------------------------------------------------------------
  # The CHANGE_ME_* values above land in the Nix store in plaintext, which
  # is world-readable on most systems. Fine for a first working config /
  # learning purposes, but before running this for real, swap these for
  # something like agenix or sops-nix and reference the decrypted secret
  # file path in `environment`/`environmentFiles` instead of inlining
  # literal passwords here.
}
