    (final: prev: {
      containerlab = prev.containerlab.overrideAttrs (finalAttrs: previousAttrs: {
        version = "0.77.0";
        src = prev.fetchFromGitHub {
          inherit (previousAttrs.src) owner repo;
          rev = "v${finalAttrs.version}";
        ##  #  # to geht hash:
          #hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
          #hash = prev.lib.fakeHash;
          #hash = "sha256-QBv0SZ7XxVc0yWbOxPKdfzk9AKYlMJyeZwpAx1jbamk="; # 0.72.0
          #hash = "sha256-i2DTa5PZOWRgUIhlX3l2mnz+o6yEPkRZY/NrG73pbj4="; # 0.73
          #hash = "sha256-8hpLUWEMmEinIhjzjvPa8lU+GsjtZGTg36bZWujgnp4="; # 0.74
          #hash = "sha256-MtmUd5ebDN4flcnG+oMMGRUrV11fhVFEr8wfUuP8fJc="; # 0.74.3
          #hash = "sha256-l04WV3dvi09Gc/ywxTcGW0YY221vf9XelGAZcTaR17o="; # 0.75.0
          #hash = "sha256-ULO0I9ixhRKCHI6LT2lWn2wXEIMl87q3PXwus+b3VmM="; # 0.76.0
          hash = "sha256-39rjb9GU37lGvNO45ibNfsbEkuzXuS4X5jyhDWXfMMc="; # 0.77.0
        };
        # # to get vendorHash:
        # #    vendorHash = lib.fakeHash;
        #vendorHash = prev.lib.fakeHash;
        #vendorHash = "sha256-XttJ/GXhNKVHLR33A/o3N3OYHsyKWHBhD5QOz0AlfFk="; # 0.72.0
        #vendorHash = "sha256-oyWoyVq2LM5Dhi6REFSrtbtFR4HtyeJvsbrZeY2nxkI="; # 0.73
        #vendorHash = "sha256-hw7Dln+ur2fBA1InMvJ0J86nGM+ts0DW4ZjU11h7Wyw="; # 0.74
        #vendorHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB";
        #vendorHash = "sha256-hw7Dln+ur2fBA1InMvJ0J86nGM+ts0DW4ZjU11h7Wyw="; # 0.74.3
        #vendorHash = "sha256-NOw57ly/RhH7g98uMDQyZ8cUsnvjl14oc75VQMROPgY="; # 0.75.0
        #vendorHash = "sha256-US8y4AlO9fMD7bogIPT6bsrSsUx7c6X1Y0ooHiQ6WUc="; # 0.76.0
        vendorHash = "sha256-EPkztm+7LgSB58ZFKViW4qlGhw+9zSNlJa4AKsZPfzs="; # 0.77.0
        ldflags = [
          #"-linkmode external"
          #"-extldflags '-static'"
          "-s"
          "-w"
          "-X github.com/srl-labs/containerlab/cmd.Version=${finalAttrs.version}"
          "-X github.com/srl-labs/containerlab/cmd.commit=${finalAttrs.src.rev}"
          "-X github.com/srl-labs/containerlab/cmd.date=1970-01-01T00:00:00Z"
        ];
        # meta = {
        #   inherit (previousAttrs.meta) description homepage license platforms maintainers mainProgram;
        #   changelog = "https://github.com/srl-labs/containerlab/releases/tag/${finalAttrs.src.rev}";
        # };
        #ldflags = [
        #  "-s"
        #  "-w"
        #  "-X github.com/srl-labs/containerlab/cmd/version.Version=${finalAttrs.version}"
        #  "-X github.com/srl-labs/containerlab/cmd/version.commit=${finalAttrs.src.rev}"
        #  "-X github.com/srl-labs/containerlab/cmd/version.date=1970-01-01T00:00:00Z"
        #];
        #postinstall: (does not work like that)
        #sudo chmod +s "$out/bin/containerlab"

        # TestVerifyLinks wants to use docker.sock, which is not available in the Nix build environment.
        checkFlags = [
          "-skip=^TestVerifyLinks$|^TestIsKernelModuleLoaded$"
        ];

        postInstall = ''
          ln -sf "$out/bin/containerlab" "$out/bin/clab"
        '';
      });
    })
