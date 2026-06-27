{
  config,
  pkgs,
  lib,
  ...
}:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.art = { pkgs, config, ... }: {
    home.stateVersion = "26.05";

    # Force dark GTK theme as an env var — some apps (including Brave)
    # read this directly rather than querying the portal
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
      # These two tell GTK3/4 apps to prefer dark without needing an env var
      gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
    };

    # This is what the portal reads when Brave asks "is the OS in dark mode?"
    # Without this, Brave's "Use system theme" will randomly pick light
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
        # Without this package, the style name silently does nothing
        package = pkgs.adwaita-qt;
      };
    };

    # adwaita-qt6 is separate from adwaita-qt (covers Qt5 only)
    home.packages = with pkgs; [
      adwaita-qt6
    ];
  };

  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland # was missing — needed for Brave/screenshare
      xdg-desktop-portal-gtk # handles FileChooser and Settings
    ];
    config = {
      common = {
        default = [
          "gtk"
        ];
      };
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        # Explicitly route these to GTK so the file picker always works
        # and dark mode queries return the correct answer
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
      };
    };
  };
}
