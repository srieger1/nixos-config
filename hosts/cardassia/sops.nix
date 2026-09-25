{ private, ... }:

{
  sops.defaultSopsFile = ../../secrets/cardassia.yaml;
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

  # atticd RS256 JWT signing secret; content is a one-line environment file:
  #   ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=<openssl genrsa -traditional 4096 | base64 -w0>
  # Read by systemd (root) as EnvironmentFile — 0400 root-owned is fine.
  sops.secrets.attic_rs256_secret = {
    mode = "0400";
  };
}
