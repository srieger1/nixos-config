{ self, config, lib, pkgs, private, ... }: {
  # Based on https://carjorvaz.com/posts/the-holy-grail-nextcloud-setup-made-easy-by-nixos/

  # acme let's encrypt certs
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = private.acmeEmail;
      dnsProvider = "hetzner";
      #dnsProvider = "cloudflare"; 
      # location of your CLOUDFLARE_DNS_API_TOKEN=[value]
      # https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#EnvironmentFile=
      #environmentFile = "/etc/cloudflare/cloudflare_dns_api_token";
      environmentFile = "/etc/hetzner/hetzner_api_key";
    };
  };

  services = {
    # nginx - move to separate nix file?
    nginx.virtualHosts = {
      ${private.nextcloudHostname} = {
        forceSSL = true;
        enableACME = true;
        # Use DNS Challenge.
        acmeRoot = null;
        listen = [
          {port = 443;  addr="0.0.0.0"; ssl = true;}
          {port = 24744;  addr="0.0.0.0"; ssl = true;}
          {port = 443;  addr="[::]"; ssl = true;}
          {port = 24744;  addr="[::]"; ssl = true;}
        ];
        # recommended for collabora code is a separate fqdn, e.g., in https://discourse.nixos.org/t/enabling-nextcloud-office/31349/2
        # but clashes with nextcloud are highly unlikely, as I used it like this for years on the old cardassia/ix config
        extraConfig = ''
          # static files
          location ^~ /browser {
            proxy_pass http://127.0.0.1:9980;
            proxy_set_header Host $host;
          }
          # WOPI discovery URL
          location ^~ /hosting/discovery {
            proxy_pass http://127.0.0.1:9980;
            proxy_set_header Host $host;
          }
          # Capabilities
          location ^~ /hosting/capabilities {
            proxy_pass http://127.0.0.1:9980;
            proxy_set_header Host $host;
          }
          # main websocket
          location ~ ^/cool/(.*)/ws$ {
            proxy_pass http://127.0.0.1:9980;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header Host $host;
            proxy_read_timeout 36000s;
          }
          # download, presentation and image upload
          location ~ ^/(c|l)ool {
            proxy_pass http://127.0.0.1:9980;
            proxy_set_header Host $host;
          }
          # Admin Console websocket
          location ^~ /cool/adminws {
            proxy_pass http://127.0.0.1:9980;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header Host $host;
            proxy_read_timeout 36000s;
          }
        '';
      };
    };

    #nginx.virtualHosts.${private.collaboraHostname} = {
    #  forceSSL = true;
    #  enableACME = true;
    #  # Use DNS Challenge.
    #  acmeRoot = null;
    #  listen = [
    #    {port = 443;  addr="0.0.0.0"; ssl = true;}
    #    {port = 24745;  addr="0.0.0.0"; ssl = true;}
    #    {port = 443;  addr="[::]"; ssl = true;}
    #    {port = 24745;  addr="[::]"; ssl = true;}
    #  ];
    #  #locations = {
    #  #  # adapted from https://sdk.collaboraonline.com/docs/installation/Proxy_settings.html#reverse-proxy-with-nginx-webserver
    #  #
    #  #  # static files
    #  #  "^~ /browser" = {
    #  #    proxyPass = "http://127.0.0.1:9980";
    #  #    extraConfig = ''
    #  #      proxy_set_header Host $host;
    #  #    '';
    #  #  };
    #  #
    #  #  # WOPI discovery URL
    #  #  "^~ /hosting/discovery" = {
    #  #    proxyPass = "http://127.0.0.1:9980";
    #  #    extraConfig = ''
    #  #      proxy_set_header Host $host;
    #  #    '';
    #  #  };
    #  #
    #  #  # Capabilities
    #  #  "^~ /hosting/capabilities" = {
    #  #    proxyPass = "http://127.0.0.1:9980";
    #  #    extraConfig = ''
    #  #      proxy_set_header Host $host;
    #  #    '';
    #  #  };
    #  #
    #  #  # main websocket
    #  #  "~ ^/cool/(.*)/ws$" = {
    #  #    proxyPass = "http://127.0.0.1:9980";
    #  #    extraConfig = ''
    #  #      proxy_set_header Upgrade $http_upgrade;
    #  #      proxy_set_header Connection "Upgrade";
    #  #      proxy_set_header Host $host;
    #  #      proxy_read_timeout 36000s;
    #  #    '';
    #  #  };
    #  #
    #  #  # download, presentation and image upload
    #  #  "~ ^/(c|l)ool" = {
    #  #    proxyPass = "http://127.0.0.1:9980";
    #  #    extraConfig = ''
    #  #      proxy_set_header Host $host;
    #  #    '';
    #  #  };
    #  #
    #  #  # Admin Console websocket
    #  #  "^~ /cool/adminws" = {
    #  #    proxyPass = "http://127.0.0.1:9980";
    #  #    extraConfig = ''
    #  #      proxy_set_header Upgrade $http_upgrade;
    #  #      proxy_set_header Connection "Upgrade";
    #  #      proxy_set_header Host $host;
    #  #      proxy_read_timeout 36000s;
    #  #    '';
    #  #  };
    #  #
    #  #};
    #};

    # nextcloud
    nextcloud = {
      enable = true;
      hostName = private.nextcloudHostname;
      # Need to manually increment with every major upgrade.
      package = pkgs.nextcloud33;
      # Let NixOS install and configure the database automatically.
      database.createLocally = true;
      # Let NixOS install and configure Redis caching automatically.
      configureRedis = true;
      # Increase the maximum file upload size.
      maxUploadSize = "16G";
      https = true;
      autoUpdateApps.enable = true;
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        # List of apps we want to install and are already packaged in
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
        #inherit calendar contacts notes onlyoffice tasks cookbook qownnotesapi;
        inherit calendar contacts notes tasks cookbook qownnotesapi richdocuments;
        # Custom app example.
        #socialsharing_telegram = pkgs.fetchNextcloudApp rec {
        #  url =
        #    "https://github.com/nextcloud-releases/socialsharing/releases/download/v3.0.1/socialsharing_telegram-v3.0.1.tar.gz";
        #  license = "agpl3";
        #  sha256 = "sha256-8XyOslMmzxmX2QsVzYzIJKNw6rVWJ7uDhU1jaKJ0Q8k=";
        #};
      };
      settings = {
        overwriteprotocol = "https";
        default_phone_region = "DE";
        trusted_domains = [ private.nextcloudHostname private.collaboraHostname ];
        # ionos1
        trusted_proxies = private.trustedProxies;
        # old fastly ips:
        #trusted_proxies = [ "127.0.0.1" "23.235.32.0/20" "43.249.72.0/22" "103.244.50.0/24" "103.245.222.0/23"
        #  "103.245.224.0/24" "104.156.80.0/20" "140.248.64.0/18" "140.248.128.0/17" "146.75.0.0/17" "151.101.0.0/16" "157.52.64.0/18"
        #  "167.82.0.0/17" "167.82.128.0/20" "167.82.160.0/20" "167.82.224.0/20" "172.111.64.0/18" "185.31.16.0/22" "199.27.72.0/21"
        #  "199.232.0.0/16" "2a04:4e40::/32" "2a04:4e42::/32"
        #];
        # old cloudflare ips:
	#trusted_proxies = [ "10.42.0.0/16" "103.21.244.0/22" "103.22.200.0/22" "103.31.4.0/22" "104.16.0.0/12"
        #  "108.162.192.0/18" "131.0.72.0/22" "141.101.64.0/18" "162.158.0.0/15" "172.64.0.0/13" "173.245.48.0/20"
        #  "188.114.96.0/20" "190.93.240.0/20" "197.234.240.0/22" "198.41.128.0/17" "2400:cb00::/32" "2606:4700::/32"
        #  "2803:f800::/32" "2405:b500::/32" "2405:8100::/32" "2c0f:f248::/32"
        #];
        log_type = "file";
        maintenance_window_start = 1;
      };
      config = {
        dbtype = "pgsql";
        adminuser = "admin";
        adminpassFile = "/etc/nextcloud/nextcloud_adminpass";
      };
      # Suggested by Nextcloud's health check.
      phpOptions."opcache.interned_strings_buffer" = "16";
    };
    # Nightly database backups.
    postgresqlBackup = {
      enable = true;
      startAt = "*-*-* 01:15:00";
    };
  };

  #Collabora Containers
  virtualisation.oci-containers.containers.collabora = {
    image = "docker.io/collabora/code:latest";
    ports = [ "9980:9980/tcp" ];
    autoStart = true;
    environment = {
      server_name = private.nextcloudHostname;
      # removed DONT_GEN_SSL_CERT — Collabora 26.x initializes SSL context even with
      # ssl.enable=false and crashes if no key exists; let the container generate self-signed certs
      aliasgroup1 = "https://${private.nextcloudHostname}:443";
      #aliasgroup2 = "https://${private.collaboraHostname}:443";
      dictionaries = "de_DE en_GB en_US";
      extra_params = "--o:home_mode.enable=true --o:ssl.enable=false --o:ssl.termination=true";
      SLEEPFORDEBUGGER = "0";
    };
    # username and password are read from /etc/collabora/credentials (KEY=VALUE format, not tracked in git)
    environmentFiles = [ "/etc/collabora/credentials" ];
    # newer Collabora versions require ca-chain.cert.pem even with ssl.enable=false;
    # system CA bundle is world-readable and contains Let's Encrypt roots
    volumes = [ "/etc/ssl/certs/ca-bundle.crt:/etc/coolwsd/ca-chain.cert.pem:ro" ];
    # currently only available in unstable https://search.nixos.org/options?channel=unstable&show=virtualisation.oci-containers.containers.%3Cname%3E.capabilities&from=0&size=50&sort=relevance&type=packages&query=virtualisation.oci-containers
    # therefore using extraOption for now
    #capabilities = [
    #  "MKNOD" = true;
    #];
    extraOptions = ["--cap-add" "MKNOD" "--pull" "newer" "--no-healthcheck"];
    #extraOptions = [ 
    #  #"--cap-add=MKNOD --pull=newer"
    #  "--pull=newer"
    #];  
  };
}
