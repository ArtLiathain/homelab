{
  config,
  pkgs,
  lib,
  ...
}:

{

  system.activationScripts.zz-deploy-dotfiles = ''
    HOME_DIR="/home/art"
    DOTFILES_DIR="$HOME_DIR/.dotfiles"
    DOTFILES_REPO="https://github.com/ArtLiathain/dotfiles.git"

    if [ ! -d "$DOTFILES_DIR/.git" ]; then
      rm -rf "$DOTFILES_DIR"
      ${pkgs.git}/bin/git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
      cd "$DOTFILES_DIR"
      ${pkgs.git}/bin/git remote set-url origin git@github.com:ArtLiathain/dotfiles.git
      chown -R art:users "$DOTFILES_DIR"
    fi

    cd "$DOTFILES_DIR"
    ${pkgs.git}/bin/git diff --quiet && ${pkgs.git}/bin/git pull --ff-only || true

    # Ensure scripts are executable (git doesn't reliably track permissions)
    chmod +x "$DOTFILES_DIR/home/scripts"/*.sh

    mkdir -p /home/art/.config /home/art/scripts /home/art/wallpapers
    ${pkgs.stow}/bin/stow --adopt --restow -d "$DOTFILES_DIR/config" -t /home/art/.config .
    ${pkgs.stow}/bin/stow --adopt --restow -d "$DOTFILES_DIR/home" -t /home/art .
    chown -R art:users /home/art

    if [ ! -f "$HOME_DIR/.cache/wallust/colors_neopywal.vim" ]; then
     ${pkgs.su}/bin/su - art -c "${pkgs.bash}/bin/bash /home/art/scripts/process_wallpaper.sh /home/art/wallpapers/default_wallpaper.jpg"
    fi
  '';


}
