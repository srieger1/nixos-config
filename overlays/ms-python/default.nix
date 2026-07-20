    (final: prev: {
      vscode-extensions.ms-python.python = prev.vscode-extensions.ms-python.python.overrideAttrs (finalAttrs: previousAttrs: { 
        mktplcRefsrc = prev.vscode-utils.buildVscodeMarketplaceExtension rec {
          inherit (previousAttrs.mktplcRefsrc) name publisher;
          version = "2025.2.0";
          hash = "sha256-f573A/7s8jVfH1f3ZYZSTftrfBs6iyMWewhorX4Z0Nc=";
        };
      });
    })
