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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  programs.nix-ld.enable = true;

  services.openssh = {
    enable = true;
  };

  programs.zsh.enable = true;
  users.users.art = {
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };
  users.mutableUsers = false;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };


  environment.systemPackages = with pkgs; [
    git
    neovim
    curl
    wget
  ];
imports =[
    ./tailscale.nix
];
}


