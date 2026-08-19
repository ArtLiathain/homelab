{
  config,
  pkgs,
  lib,
  ...
}:

{

  system.activationScripts.zz-deploy-dotfiles = ''
    export HOME=/home/art
    DOTFILES_DIR="$HOME/.dotfiles"
    DOTFILES_REPO="https://github.com/ArtLiathain/dotfiles.git"

    if [ ! -d "$DOTFILES_DIR/.git" ]; then
      rm -rf "$DOTFILES_DIR"
      ${pkgs.git}/bin/git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
      ${pkgs.git}/bin/git -C "$DOTFILES_DIR" remote set-url origin git@github.com:ArtLiathain/dotfiles.git
      chown -R art:users "$DOTFILES_DIR"
    fi

    ${pkgs.git}/bin/git -C "$DOTFILES_DIR" pull --ff-only 2>/dev/null || true

    shopt -s nullglob
    for f in "$DOTFILES_DIR/home/scripts"/*.sh; do
      chmod +x "$f"
    done
    shopt -u nullglob

    mkdir -p "$HOME/.config" "$HOME/scripts" "$HOME/wallpapers"
    ${pkgs.stow}/bin/stow --adopt --restow -d "$DOTFILES_DIR/config" -t "$HOME/.config" .
    ${pkgs.stow}/bin/stow --adopt --restow -d "$DOTFILES_DIR/home" -t "$HOME" .
    chown -R art:users "$HOME"

    if [ ! -f "$HOME/.cache/wallust/colors_neopywal.vim" ]; then
     ${pkgs.su}/bin/su - art -c "${pkgs.bash}/bin/bash $HOME/scripts/process_wallpaper.sh $HOME/wallpapers/default_wallpaper.jpg"
    fi
  '';


}
