{ config, lib, pkgs, ... }:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    waybar
    rofi-wayland
    dunst
    swww
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
