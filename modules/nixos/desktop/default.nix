{ config
, pkgs
, lib
, ...
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
    hashedPasswordFile = "/etc/nixos/art-password";
  };
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;
  };
  services.displayManager.defaultSession = "hyprland";

  programs.qylock = {
    enable = true;
    theme = "nier-automata";
    themeOptions = {
      terraria.backgroundMode = "time";
      Genshin.backgroundMode = "time";
      clockwork.orbital = { themeMode = "dark"; enableWindup = true; };
      osu.gameMode = "menu";
    };
  };

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
    nixd
    ruff
    prettierd
    shfmt
    nixpkgs-fmt
    stylua
    uv

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
