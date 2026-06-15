{ config, lib, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Europe/Dublin";

  i18n.defaultLocale = "en_IE.UTF-8";

  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;

  hardware.enableRedistributableFirmware = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  programs.nix-ld.enable = true;

  services.openssh = {
    enable = true;
  };

  programs.git = {
    enable = true;
    config = {
      user.name = "ArtLiathain";
      user.email = "artp.oliathain@gmail.com";
    };
  };

  programs.zsh.enable = true;
  users.users.art = {
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
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


