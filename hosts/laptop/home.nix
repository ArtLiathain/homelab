{ pkgs, ... }: {
  imports = [
    ../../modules/home/autostart.nix
    ../../modules/home/git.nix
    ../../modules/home/shell.nix
    ../../modules/home/desktop-apps.nix
  ];
}
