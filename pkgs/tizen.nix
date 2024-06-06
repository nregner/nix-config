{
  jre8_headless,
  lib,
  makeWrapper,
  runCommand,
  unzip,
}:
let
  src = builtins.fetchurl {
    url = "https://download.tizen.org/sdk/Installer/tizen-studio_5.6/web-cli_Tizen_Studio_5.6_ubuntu-64.bin";
    sha256 = "ichPvEdNz7Aq8ZO8x2Pi578yWb80y/a39E7C2gJNt98=";
  };
  # bypass the OS-specific installer and just extract the tarball
  # see `head web-cli_Tizen_Studio_5.6_ubuntu-64.bin`
  tarball = "tail -n +171 ${src}";
  sdk = runCommand "tizen-studio_5.6" { nativeBuildInputs = [ unzip ]; } ''
    md5=$(${tarball} | md5sum)
    if [ "$md5" != '4872b72c691f8c73b34d339346ac0ee5  -' ]; then
      echo "The download file appears to be corrupted: $md5"
      exit 1
    fi
    ${tarball} | tar xmz tizen-sdk.zip

    mkdir $out
    unzip tizen-sdk.zip -x 'jdk/*' 'package-manager/*' -d $out

    patchShebangs $out/tools/ide/bin/tizen.sh

    # these files must exist to run the CLI...
    # ideally we could get TIZEN_SDK_DATA_PATH from an environment variable
    cat > "$out/sdk.info" << EOF
    TIZEN_SDK_INSTALLED_PATH=$out
    TIZEN_SDK_DATA_PATH=/tmp/tizen-sdk
    EOF
    touch $out/tools/.tizen-cli-config
  '';
in
runCommand "tizen"
  {
    nativeBuildInputs = [ makeWrapper ];
    runtimeInputs = [ jre8_headless ];
    passthru = {
      inherit src sdk;
    };
  }
  ''
    # wrap the script... it uses relative paths internally
    makeWrapper ${sdk}/tools/ide/bin/tizen.sh $out/bin/tizen \
      --prefix PATH : ${lib.makeBinPath [ jre8_headless ]}
  ''
