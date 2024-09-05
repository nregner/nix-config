{
  sources,
  luajit,
  stdenv,
}:

stdenv.mkDerivation (
  sources.antifennel
  // {
    buildInputs = [ luajit ];

    makeFlags = [
      "DESTDIR=$(out)"
      "PREFIX="
    ];

    postInstall = ''
      patchShebangs $out/bin/antifennel
    '';

    meta = {
      homepage = "https://git.sr.ht/~technomancy/antifennel";
      description = "Turn Lua code into Fennel code";
      # license = lib.licenses.gpl3Plus;
      # platforms = lib.platforms.linux;
    };
  }
)
