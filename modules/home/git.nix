{ pkgs, ... }: {
  programs.git = {
    enable = true;
    settings.user.name = "ArtLiathain";
    settings.user.email = "artp.oliathain@gmail.com";
  };
}
