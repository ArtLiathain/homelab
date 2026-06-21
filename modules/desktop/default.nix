{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./theming.nix
  ];

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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  users.mutableUsers = false;

  programs.zsh.enable = true;
  users.users.art = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "video"
      "audio"
    ];
    hashedPassword = "$6$sTFYLSFGY/D7LIJ9$9bVUCMuMwjoqExwlKm71oqiyRUfWZnTfxMZas36NIexGBAqeiBC4L4YJ8rZHRnyqgfcyxMvU4S8xQGw3Lb8RJ0";
  };
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;
  };
  services.displayManager.defaultSession = "hyprland-uwsm";

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
    zoxide
    yazi

    # Development
    bash-language-server
    bun
    check
    clang
    clang-tools
    cmake
    delve
    gopls
    llvm
    lua-language-server
    marksman
    meson
    nil
    ninja
    omnisharp-roslyn
    pyright
    python3
    rust-analyzer
    rustup
    stylua
    taplo
    tinymist
    typescript-language-server
    ripgrep
    vscode-langservers-extracted
    yaml-language-server
    zls
    opencode

    # Desktop
    brave
    obsidian
    wezterm
    kitty
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
    monospace = [
      "JetBrainsMono Nerd Font"
      "Hack Nerd Font"
    ];
    sansSerif = [
      "Noto Sans"
      "DejaVu Sans"
    ];
    serif = [
      "Noto Serif"
      "DejaVu Serif"
    ];
  };

  services.xserver.excludePackages = [ pkgs.xterm ];

  system.activationScripts.zz-deploy-dotfiles = ''
    DOTFILES_DIR="/home/art/.dotfiles"
    DOTFILES_REPO="https://github.com/ArtLiathain/dotfiles.git"

    if [ ! -d "$DOTFILES_DIR/.git" ]; then
      rm -rf "$DOTFILES_DIR"
      ${pkgs.git}/bin/git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
      cd "$DOTFILES_DIR"
      ${pkgs.git}/bin/git remote set-url origin git@github.com:ArtLiathain/dotfiles.git
      chown -R art:users "$DOTFILES_DIR"
    fi

    cd "$DOTFILES_DIR"
    ${pkgs.git}/bin/git diff --quiet && ${pkgs.git}/bin/git pull --ff-only || true

    # Ensure scripts are executable (git doesn't reliably track permissions)
    chmod +x "$DOTFILES_DIR/home/scripts"/*.sh

    mkdir -p /home/art/.config /home/art/scripts /home/art/wallpapers
    ${pkgs.stow}/bin/stow --adopt --restow -d "$DOTFILES_DIR/config" -t /home/art/.config .
    ${pkgs.stow}/bin/stow --adopt --restow -d "$DOTFILES_DIR/home" -t /home/art .
    chown -R art:users /home/art
  '';

  system.activationScripts.zz-run-wallust = ''
    ${pkgs.su}/bin/su - art -c "${pkgs.bash}/bin/bash /home/art/scripts/process_wallpaper.sh /home/art/wallpapers/default_wallpaper.jpg"
  '';

}
