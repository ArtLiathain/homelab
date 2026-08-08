{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/core
    ../../modules/nixos/homelab
  ];

  networking.hostName = "homelab";
  networking.networkmanager.wifi.powersave = false;

  users.users.art = {
    isNormalUser = true;
    group = "art";
    extraGroups = [ "media" ];
    packages = with pkgs; [ tree ];
    hashedPasswordFile = "/etc/nixos/art-password";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICDoc8RFspnTgdAXya6UXYUsQGDybsbPjfZ7VwmBL1eP art@AWInc"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGI80jgXTTYoeB3UHhRT2LAVvwL5928ncrHUAyJNo7JM art.oliathain@gmail.com"
    ];
  };

  users.groups.art = { };

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

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.art = import ./home.nix;
  };

  system.stateVersion = "25.11";
}
