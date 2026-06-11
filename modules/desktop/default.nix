{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  users.mutableUsers = false;

  programs.zsh.enable = true;
  users.users.art = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "video" "audio" ];
    hashedPassword = "$6$sTFYLSFGY/D7LIJ9$9bVUCMuMwjoqExwlKm71oqiyRUfWZnTfxMZas36NIexGBAqeiBC4L4YJ8rZHRnyqgfcyxMvU4S8xQGw3Lb8RJ0";
  };
services.xserver.enable = true;
services.displayManager.sddm = {
  enable = true;
  wayland.enable = true;
};
services.displayManager.defaultSession = "hyprland";

  environment.systemPackages = with pkgs; [
    # CLI
    bat
    brightnessctl
    fd
    fastfetch
    fzf
    htop
    jless
    jq
    lazygit
    lsof
    tmux
    tree-sitter
    typst
    usbutils
    wl-clipboard
    zip
    unzip
    p7zip
    stow

    # Development
    bun
    check
    clang
    cmake
    llvm
    meson
    ninja
    python3
    rustup
    opencode

    # Desktop
    brave
    obsidian
    wezterm
    vesktop
    zoom-us
    spotify
    spotify-player
    zathura
    obs-studio
    kdePackages.kdenlive
    prusa-slicer
    ghostscript
    ffmpeg

    # Media / Graphics
    grim
    imagemagick
    pavucontrol
    slurp
    sox
    swappy

    # Theming
    hyprcursor
    hyprpaper
    mako
    rofi
    wallust
    waybar
    wofi

    # Bluetooth
    bluetui

    # Editors
    neovim

    # Basics
    git
    wget
    curl
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    dejavu_fonts
    font-awesome
nerd-fonts.jetbrains-mono
    nerd-fonts.hack
    material-design-icons
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [ "JetBrainsMono Nerd Font" "Hack Nerd Font" ];
    sansSerif = [ "Noto Sans" "DejaVu Sans" ];
    serif = [ "Noto Serif" "DejaVu Serif" ];
  };

  services.xserver.excludePackages = [ pkgs.xterm ];

system.activationScripts.stow-dotfiles = ''
  ${pkgs.stow}/bin/stow --adopt -d ${../../dotfiles/config} -t /home/art/.config .
  ${pkgs.stow}/bin/stow --adopt -d ${../../dotfiles/home} -t /home/art .
  chown -R art:users /home/art
'';

system.activationScripts.run-wallust = ''
    ${pkgs.su}/bin/su - art -c "${pkgs.bash}/bin/bash /home/art/scripts/set-wallpaper.sh /home/art/wallpapers/default_wallpaper.jpg"
    '';


}
