{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7PGxz3DzunS2JcK4WtmBv0F79QJfAT1KSSDgm5gB2k="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  users.users.art = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "video" "audio" ];
    shell = pkgs.zsh;
  };

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

    # Desktop
    brave
    obsidian
    wezterm
    vesktop
    zoom-us
    spotify
    spotify-player
    zathura
    zathura_pdf_mupdf
    obs-studio
    kdenlive
    prusa-slicer
    libreoffice-fresh
    ghostscript
    ffmpeg

    # Media / Graphics
    android-file-transfer
    grim
    imagemagick
    pavucontrol
    slurp
    sox
    swappy

    # Theming
    catppuccin-gtk
    hyprcursor
    hyprpaper
    mako
    rofi-wayland
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
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
    dejavu_fonts
    font-awesome
    (nerdfonts.override { fonts = [ "JetBrainsMono" "Hack" ]; })
    material-design-icons
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [ "JetBrainsMono Nerd Font" "Hack Nerd Font" ];
    sansSerif = [ "Noto Sans" "DejaVu Sans" ];
    serif = [ "Noto Serif" "DejaVu Serif" ];
  };

  services.xserver.excludePackages = [ pkgs.xterm ];
}
