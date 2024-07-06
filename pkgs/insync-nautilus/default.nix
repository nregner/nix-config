{
  dpkg,
  fetchurl,
  lib,
  nautilus,
  nautilus-python,
  python3,
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "insync-nautilus";
  version = "3.8.2.50468";

  src = fetchurl {
    url = "https://cdn.insynchq.com/builds/linux/insync-nautilus_${version}_all.deb";
    sha256 = "sha256-GGxVH/oz2G0BAlcbBGwfNM8aH0invh319azSqgflMXs=";
  };

  strictDeps = true;
  nativeBuildInputs = [ dpkg ];
  buildInputs = [
    nautilus
    nautilus-python
    python3
  ];

  dontBuild = true;

  installPhase = ''
    mkdir $out
    dpkg -x $src tmp
    cp -r tmp/usr/share $out
    chmod +x $out/share/nautilus-python/extensions/insync-nautilus-plugin.py
    patchShebangs $out/share/nautilus-python/extensions/insync-nautilus-plugin.py
  '';

  meta = {
    homepage = "https://www.insynchq.com/downloads/linux#nautilus";
    description = "Insync nautilus integration";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
