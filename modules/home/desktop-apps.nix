{ pkgs, ... }: {
  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
      icon-theme = "Papirus";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  home.packages = with pkgs; [
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
    notion-app-enhanced

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

    # Theming dependencies
    adwaita-qt6
  ];

  systemd.user.services.brave-browser = {
    Unit = {
      Description = "Brave Browser autostart";
      After = [
        "graphical-session.target"
        "xdg-desktop-portal.service"
        "xdg-desktop-portal-gtk.service"
      ];
    };
    Service = {
      Type = "exec";
      ExecStart = "${pkgs.brave}/bin/brave";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
