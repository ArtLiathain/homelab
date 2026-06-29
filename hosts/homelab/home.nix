{ pkgs, ... }: {
  imports = [
    ../../modules/home/git.nix
    ../../modules/home/shell.nix
  ];
}
