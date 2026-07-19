{ pkgs, ... }:

let
  guiApps = [
    { id = "brave"; name = "Brave Browser"; pkg = pkgs.brave; bin = "brave"; }
    { id = "vesktop"; name = "Vesktop"; pkg = pkgs.vesktop; bin = "vesktop"; }
    { id = "obsidian"; name = "Obsidian"; pkg = pkgs.obsidian; bin = "obsidian"; }
  ];

  startTerminalGUIs = pkgs.writeShellScript "start-terminal-guis" ''
    ${pkgs.wezterm}/bin/wezterm start --class Programming -- zsh -c "tmux new-session -A -s main 'fastfetch -c examples/15.jsonc; exec zsh'" &
    ${pkgs.wezterm}/bin/wezterm start --class SpotifyPlayer -- ${pkgs.spotify-player}/bin/spotify_player &
  '';

in
{
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };
  };
  services.hyprpaper.enable = true;

  systemd.user.services =
    let
      portalWait = [
        "graphical-session.target"
        "xdg-desktop-portal.service"
        "xdg-desktop-portal-gtk.service"
      ];
    in
    {
      start-terminal-guis = {
        Unit = {
          Description = "Terminal GUI Autostart (Wezterm + Spotify)";
          After = portalWait;
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${startTerminalGUIs}";
          RemainAfterExit = true;
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    } // builtins.listToAttrs (map
      (app: {
        name = "${app.id}-autostart";
        value = {
          Unit = {
            Description = "${app.name} autostart";
            After = portalWait;
          };
          Service = {
            Type = "exec";
            ExecStart = "${app.pkg}/bin/${app.bin}";
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
      })
      guiApps);
}
