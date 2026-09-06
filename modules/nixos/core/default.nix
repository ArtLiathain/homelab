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
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.useOSProber = true;
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

  # Shared `art` login password, managed via sops. sops-nix decrypts this
  # using the host's SSH host key and writes it to /etc/nixos/art-password
  # (referenced as hashedPasswordFile). Every host that imports this core
  # module provisions it, so `art-password.yaml` lists all hosts as recipients.
  # `neededForUsers` ensures decryption runs before the users activation
  # writes /etc/shadow, so hashedPasswordFile never races the secret.
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.secrets."art-password" = {
    sopsFile = ../../../secrets/art-password.yaml;
    path = "/etc/nixos/art-password";
    neededForUsers = true;
  };


  boot.loader.grub.configurationLimit = 5;

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
    nodejs
    age
    sops
    ssh-to-age
  ];
  imports = [
    ./tailscale.nix
  ];
}


