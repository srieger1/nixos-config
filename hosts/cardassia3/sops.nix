{ private, ... }:

{
  sops.defaultSopsFile = ../../secrets/cardassia3.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets.hetzner_api_key = {
    path = "/etc/hetzner/hetzner_api_key";
    owner = "acme";
    group = "acme";
    mode = "0400";
  };

  sops.secrets.nextcloud_adminpass = {
    path = "/etc/nextcloud/nextcloud_adminpass";
    owner = "nextcloud";
    group = "nextcloud";
    mode = "0400";
  };

  sops.secrets.collabora_credentials = {
    path = "/etc/collabora/credentials";
    mode = "0400";
  };

  # path avoids embedding the tunnel UUID; configuration.nix references this path
  # cloudflared uses DynamicUser — no static user entry, file stays root-owned
  sops.secrets.cloudflare_tunnel_credentials = {
    path = "/etc/cloudflare/tunnel-credentials.json";
    mode = "0400";
  };

  sops.secrets.ddclient_config = {
    path = "/run/secrets/ddclient.conf";
    mode = "0400";
  };

  # env file read by podman quadlet when starting the container;
  # must contain: LD_SUPERUSER_PASSWORD=<secret>
  sops.secrets.linkding_env = {
    path = "/run/secrets/linkding_env";
    mode = "0400";
  };
}
