{ ... }: {

  services.unmanic = {
    enable = true;
    port = 8888;
    dataDir = "/var/lib/unmanic";
    user = "unmanic";
    group = "unmanic";
    extraGroups = [ "video" "render" ];
    openFirewall = true;
  };
}
