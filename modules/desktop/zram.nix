{ config, pkgs, lib, ... }:

{
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    priority = 100;
  };
}
