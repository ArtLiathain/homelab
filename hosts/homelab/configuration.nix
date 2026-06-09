{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/core
    ../../modules/homelab
  ];

  networking.hostName = "homelab";

  users.users.art = {
    extraGroups = [ "media" ];
    packages = with pkgs; [ tree ];
    hashedPasswordFile = "/etc/nixos/art-password";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICDoc8RFspnTgdAXya6UXYUsQGDybsbPjfZ7VwmBL1eP art@AWInc"
    ];
  };

  users.groups.media = {
    members = [ "art" "radarr" "sonarr" "prowlarr" "jellyfin" "lidarr" "sabnzbd" "jellyseerr" ];
  };

  systemd.tmpfiles.rules = [
    "d /data 2775 art media - -"
    "d /data/usenet 2775 art media - -"
    "d /data/usenet/incomplete 2775 art media - -"
    "d /data/usenet/complete 2775 art media - -"
    "d /data/usenet/complete/movies 2775 art media - -"
    "d /data/usenet/complete/tv 2775 art media - -"
    "d /data/usenet/complete/music 2775 art media - -"
    "d /data/usenet/complete/books 2775 art media - -"
    "d /data/media 2775 art media - -"
    "d /data/media/movies 2775 art media - -"
    "d /data/media/tv 2775 art media - -"
    "d /data/media/music 2775 art media - -"
    "d /data/media/books 2775 art media - -"
  ];

  networking.firewall.allowedUDPPorts = [ 41641 ];

  virtualisation.docker.enable = true;

  system.stateVersion = "25.11";
}
