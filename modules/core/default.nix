{ config, lib, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Europe/Dublin";

  i18n.defaultLocale = "en_IE.UTF-8";

  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh = {
    enable = true;
    settings = {};
  };

  users.users.art = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  environment.systemPackages = with pkgs; [
    git
    neovim
    curl
    wget
  ];
}
