{ config, lib, ... }:

let
  port = 9091;
  dataDir = "/var/lib/linkding";
in
{
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 root root -"
  ];

  # Podman quadlet — systemd-generator picks this up from /etc/containers/systemd/
  environment.etc."containers/systemd/linkding.container".text = ''
    [Unit]
    Description=Linkding Bookmark Manager
    After=network-online.target
    Wants=network-online.target

    [Container]
    Image=docker.io/sissbruecker/linkding:latest
    PublishPort=${toString port}:9090
    Volume=${dataDir}:/etc/linkding/data:z
    Environment=LD_SUPERUSER_NAME=admin
    EnvironmentFile=/run/secrets/linkding_env

    [Service]
    Restart=always
    RestartSec=30

    [Install]
    WantedBy=multi-user.target default.target
  '';

  networking.firewall.allowedTCPPorts = [ port ];
}
