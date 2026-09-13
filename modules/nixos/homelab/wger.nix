# A NixOS module for running wger (Workout Manager) as a rootful Podman
# container stack, orchestrated declaratively via oci-containers.
#
# This mirrors the upstream production deployment (wger-project/docker):
#   - wger-web      : docker.io/wger/server  (Django REST + gunicorn, :8000)
#   - wger-postgres : PostgreSQL, wal_level=logical, drives wger AND
#                     PowerSync's source replication
#   - wger-cache    : Redis, used for sessions, the Django cache and the
#                     Celery broker/result backend
#   - wger-celery   : background worker (same server image)
#   - wger-beat     : Celery beat scheduler
#   - wger-powersync: journeyapps/powersync-service (offline sync for the
#                     mobile app)
#   - wger-nginx    : required frontend; serves /static/ and /media/ and
#                     routes / to wger and /ps/ to PowerSync. Upstream warns
#                     that static files break without this layer.
#
# All containers load their complete runtime environment from
# secrets/wger.env (a sops dotenv, then decrypted to /run/secrets/wger-env in
# the systemd unit), mirroring upstream's single prod.env. No credentials or
# passwords appear here or anywhere else in the Nix source.
#
# The wger image drops to USER wger (uid 1000), so the bind-mounted static,
# media and beat directories are chowned to 1000:1000 via tmpfiles.

{ config, lib, pkgs, ... }:

let
  wgerEnv = config.sops.secrets."wger-env".path;
  podmanBin = "${pkgs.podman}/bin/podman";
in
{
  imports = [ ];

  virtualisation = {
    # seafile.nix already enables containers + podman + DNS; declaring them
    # here again keeps the module self-contained if it is ever imported on
    # its own.
    containers.enable = true;

    podman = {
      enable = true;

      # We're not aliasing `docker` -> `podman` or exposing a Docker-compatible
      # socket. Nothing on this box expects /var/run/docker.sock, so leave it
      # off (matches seafile.nix).
      dockerCompat = false;

      # Containers resolve each other by name on the default network, which is
      # how the env references `wger-postgres`, `wger-cache`, `wger-web`, and
      # `wger-powersync`.
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers = {
      backend = "podman";

      containers = {

        # ---------------------------------------------------------------
        # PostgreSQL — wger's store and PowerSync's replication source
        # ---------------------------------------------------------------
        wger-postgres = {
          image = "docker.io/library/postgres:15-alpine"; # pin explicitly, upstream major
          autoStart = true;

          # POSTGRES_USER/PASSWORD/DB live in the secrets dotenv.
          environmentFiles = [ wgerEnv ];

          volumes = [
            "/var/lib/wger/postgres:/var/lib/postgresql/data"
          ];

          # PowerSync needs logical decoding (wal_level=logical).
          extraOptions = [ "--shm-size=256m" ];
          cmd = [
            "postgres"
            "-c" "wal_level=logical"
            "-c" "shared_buffers=256MB"
            "-c" "effective_cache_size=768MB"
            "-c" "work_mem=8MB"
            "-c" "random_page_cost=1.1"
            "-c" "max_connections=30"
          ];

          # No host port: only the stack needs it.
        };

        # ---------------------------------------------------------------
        # Redis — sessions, Django cache (db 1), Celery broker/backend (db 2)
        # ---------------------------------------------------------------
        wger-cache = {
          image = "docker.io/library/redis:7.4-alpine"; # pin explicitly
          autoStart = true;

          # Ephemeral cache, like upstream (no volume). Keep it from eating the
          # box and evict LRU rather than blocking new writes.
          cmd = [
            "redis-server"
            "--maxmemory" "1gb"
            "--maxmemory-policy" "volatile-lru"
          ];
        };

        # ---------------------------------------------------------------
        # wger — web UI/API. The image runs entrypoint.sh on boot: fixtures,
        # collectstatic, `manage.py migrate`, set-site-url, then gunicorn.
        # ---------------------------------------------------------------
        wger-web = {
          image = "docker.io/wger/server:2.7.0"; # pin explicitly, not :latest
          autoStart = true;

          environmentFiles = [ wgerEnv ];

          volumes = [
            "/var/lib/wger/media:/home/wger/media"
            "/var/lib/wger/static:/home/wger/static"
          ];

          dependsOn = [
            "wger-postgres"
            "wger-cache"
          ];
        };

        # ---------------------------------------------------------------
        # Celery — background worker (exercise/ingredient sync, cache warmup)
        # ---------------------------------------------------------------
        wger-celery = {
          image = "docker.io/wger/server:2.7.0";
          autoStart = true;

          environmentFiles = [ wgerEnv ];

          volumes = [
            "/var/lib/wger/media:/home/wger/media"
          ];

          cmd = [ "/start-worker" ];
        };

        # ---------------------------------------------------------------
        # Celery beat — periodic scheduler
        # ---------------------------------------------------------------
        wger-beat = {
          image = "docker.io/wger/server:2.7.0";
          autoStart = true;

          environmentFiles = [ wgerEnv ];

          volumes = [
            "/var/lib/wger/beat:/home/wger/beat"
          ];

          cmd = [ "/start-beat" ];
        };

        # ---------------------------------------------------------------
        # PowerSync — offline sync service (unified API + replication worker)
        # ---------------------------------------------------------------
        wger-powersync = {
          image = "docker.io/journeyapps/powersync-service:1.26.0"; # pin explicitly
          autoStart = true;

          environmentFiles = [ wgerEnv ];

          volumes = [
            "${./wger/powersync.yaml}:/config/powersync.yaml:ro"
            "${./wger/sync_rules.yaml}:/config/sync_rules.yaml:ro"
          ];

          cmd = [ "start" "-r" "unified" ];
        };

        # ---------------------------------------------------------------
        # nginx — required frontend (static/media) + /ps/ route to PowerSync
        # ---------------------------------------------------------------
        wger-nginx = {
          image = "docker.io/library/nginx:stable"; # pin explicitly
          autoStart = true;

          # Only reachable on the tailnet/firewall-trusted interfaces; the
          # whole stack is exposed through this single port.
          ports = [
            "0.0.0.0:8084:80"
          ];

          volumes = [
            "${./wger/nginx.conf}:/etc/nginx/conf.d/default.conf:ro"
            "/var/lib/wger/static:/wger/static:ro"
            "/var/lib/wger/media:/wger/media:ro"
          ];
        };
      };
    };
  };

  # ------------------------------------------------------------------
  # Application-level startup ordering.
  #
  # `dependsOn` only gives systemd unit-level Requires/After (fine for
  # db -> web), but it cannot express "web is actually healthy", which the
  # upstream compose does via health conditions. So we gate the dependent
  # containers behind a small readiness oneshot that reuses wger's own
  # healthcheck endpoint instead of arbitrary sleeps.
  # ------------------------------------------------------------------

  systemd.services.wger-web-ready = {
    description = "Wait until the wger web container is healthy";
    wantedBy = [ "multi-user.target" ];
    requires = [ "podman-wger-web.service" ];
    after = [ "podman-wger-web.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ok=0
      for _i in $(seq 1 90); do
        if ${podmanBin} exec wger-web wget --no-verbose --tries=1 -O /dev/null http://localhost:8000/api/v2/version/ >/dev/null 2>&1; then
          ok=1
          break
        fi
        sleep 5
      done
      if [ "$ok" != 1 ]; then
        echo "wger web did not become healthy in time (see: journalctl -u podman-wger-web.service)" >&2
        exit 1
      fi
    '';
  };

  # Idempotent PowerSync storage bootstrap: creates the powersync_storage role
  # and `powersync` schema inside the wger database (reads PS_STORAGE_PG_URI
  # from the container env). Must finish before the powersync service starts.
  systemd.services.wger-powersync-setup = {
    description = "Bootstrap PowerSync storage role and schema in PostgreSQL";
    wantedBy = [ "multi-user.target" ];
    requires = [ "wger-web-ready.service" ];
    after = [ "wger-web-ready.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${podmanBin} exec --user 0:0 wger-web python3 manage.py setup-powersync-storage
    '';
  };

  # Order the remaining containers behind the readiness/bootstrap gates. The
  # generated podman-*.service units already carry wger-web's dependsOn; we
  # only add what unit-level ordering cannot express.
  systemd.services = {
    "podman-wger-celery" = {
      requires = [ "wger-web-ready.service" ];
      after = [ "wger-web-ready.service" ];
    };

    "podman-wger-beat" = {
      requires = [ "wger-web-ready.service" "podman-wger-celery.service" ];
      after = [ "wger-web-ready.service" "podman-wger-celery.service" ];
    };

    "podman-wger-powersync" = {
      requires = [ "wger-powersync-setup.service" ];
      after = [ "wger-powersync-setup.service" ];
    };

    "podman-wger-nginx" = {
      requires = [ "podman-wger-powersync.service" "wger-web-ready.service" ];
      after = [ "podman-wger-powersync.service" "wger-web-ready.service" ];
    };
  };

  # Data dirs for the bind mounts. static/media/beat are owned by the image's
  # wger user (uid 1000); the postgres entrypoint chowns its own PGDATA.
  systemd.tmpfiles.rules = [
    "d /var/lib/wger 0755 root root -"
    "d /var/lib/wger/postgres 0700 root root -"
    "d /var/lib/wger/static 0750 1000 1000 -"
    "d /var/lib/wger/media 0750 1000 1000 -"
    "d /var/lib/wger/beat 0750 1000 1000 -"
  ];

  # Reachable over Tailscale without extra firewall holes (seafile.nix already
  # trusts tailscale0; this keeps the module self-contained if not).
  networking.firewall.trustedInterfaces = lib.mkDefault [ "tailscale0" ];
}