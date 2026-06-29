{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./activation_scripts.nix
  ];
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
  services.displayManager.defaultSession = "hyprland";

  programs.dconf.enable = true;
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
}
