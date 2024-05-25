{
  inputs,
  moonraker,
  stdenv,
}:
(moonraker.override (prev: rec {
  python3 = prev.python3.override {
    packageOverrides =
      self: super:
      let
        preprocess-cancellation =
          inputs.preprocess-cancellation.packages.${stdenv.hostPlatform.system}.default;
      in
      assert prev.python3.pkgs.hasPythonModule preprocess-cancellation;
      {
        inherit preprocess-cancellation;
      };
    self = python3;
  };
})).overrideAttrs
  (oldAttrs: {
    patches = [ ./preprocess-cancellation.patch ];
  })
