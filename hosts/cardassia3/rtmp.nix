{ config, pkgs, ... }: {
  # RTMP server (e.g. for OBS ingest) via nginx's rtmp module.
  services.nginx = {
    enable = true;
    package = pkgs.nginxStable.override {
      modules = [ pkgs.nginxModules.rtmp ];
    };

    # rtmp {} is a top-level directive (sibling of http {}), so it must be
    # appended after the generated http {} block rather than nested inside it.
    appendConfig = ''
      rtmp {
              server {
                      listen 1935;
                      chunk_size 4096;

                      application live {
                              live on;
                              record off;
                      }
              }
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [ 1935 ];
}
