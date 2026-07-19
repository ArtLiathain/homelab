{ config, lib, pkgs, ... }:

{

  time.timeZone = "Europe/Dublin";

  i18n.defaultLocale = "en_IE.UTF-8";

  networking.networkmanager.enable = true;
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  hardware.enableRedistributableFirmware = true;

  hardware.enableAllFirmware = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  programs.nix-ld.enable = true;

  services.openssh = {
    enable = true;
  };

  services.irqbalance.enable = true;

  boot.kernel.sysctl = {
    "net.core.rmem_default" = 262144;
    "net.core.rmem_max" = 4194304;
    "net.core.netdev_max_backlog" = 5000;
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  programs.zsh.enable = true;
  users.users.art = {
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };
  users.mutableUsers = false;

  environment.etc."nixos/art-password".source = ../../../secrets/art_password;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };


  environment.systemPackages = with pkgs; [
    git
    neovim
    curl
    iw
    wget
  ];
  imports = [
    ./tailscale.nix
  ];
}


