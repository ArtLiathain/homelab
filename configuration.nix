{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "homelab";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Dublin";

  i18n.defaultLocale = "en_IE.UTF-8";

  users.users.art = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "media" ];
    packages = with pkgs; [ tree ];
    hashedPasswordFile = "/etc/nixos/art-password";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICDoc8RFspnTgdAXya6UXYUsQGDybsbPjfZ7VwmBL1eP art@AWInc"
    ];
  };

  users.groups.media = {
    members = [ "art" "radarr" "sonarr" "prowlarr" "jellyfin" "qbittorrent" "lidarr"];
  };

  services.openssh = {
    enable = true;
    settings = {};
  };

  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
  ];

  systemd.tmpfiles.rules = [
    "d /data 2775 art media - -"
    "d /data/torrents 2775 art media - -"
    "d /data/torrents/movies 2775 art media - -"
    "d /data/torrents/tv 2775 art media - -"
    "d /data/torrents/music 2775 art media - -"
    "d /data/torrents/books 2775 art media - -"
    "d /data/media 2775 art media - -"
    "d /data/media/movies 2775 art media - -"
    "d /data/media/tv 2775 art media - -"
    "d /data/media/music 2775 art media - -"
    "d /data/media/books 2775 art media - -"
  ];

  networking.firewall.allowedUDPPorts = [ 41641 ];

  system.stateVersion = "25.11";
}
