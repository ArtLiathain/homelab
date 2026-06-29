{ pkgs, ... }: {
  imports = [
    ../../modules/home/git.nix
    ../../modules/home/shell.nix
    ../../modules/home/desktop-apps.nix
  ];
}
