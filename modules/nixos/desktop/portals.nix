{ config, pkgs, lib, ... }: {
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
