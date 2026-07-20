# Fix bluetooth connection
# Ref: https://github.com/jtojnar/nixfiles/commit/a3dcf3e6de1a4e3cfb21bdef15f0227fff943bc
# Once this is merged, I shouldn't need this.

(final: prev:
{
  wireplumber = prev.wireplumber.overrideAttrs (attrs: {
    version = "0.5.12";
    src = attrs.src.override {
      rev = "0.5.12";
      hash = "sha256-3LdERBiPXal+OF7tgguJcVXrqycBSmD3psFzn4z5krY=";
    };
  });
})
