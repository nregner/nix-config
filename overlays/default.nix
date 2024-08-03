{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  warnIfOutdated =
    prev: final:
    lib.warnIf (lib.versionOlder final.version prev.version)
      "${final.name} is outdated. latest: ${prev.version}"
      final;

  sharedModifications = final: prev: {
    # FIXME: hack to bypass "FATAL: Module ahci not found" error
    # https://github.com/NixOS/nixpkgs/issues/154163#issuecomment-1350599022
    makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });

    hydra_unstable = prev.hydra_unstable.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [
        ./hydra/fix-restrict-eval-does-not-allow-access-to-git-flake.patch
        ./hydra/feat-add-always_supported_system_types-option.patch
      ];
      checkPhase = "";
    });

    nodePackages_latest =
      let
        nodePkgs = prev.nodePackages_latest;
        node2nixPkgs = import ../pkgs/node2nix {
          pkgs = final;
          nodejs = nodePkgs.nodejs;
        };
      in
      nodePkgs
      // {
        graphql-language-service-cli = warnIfOutdated nodePkgs.graphql-language-service-cli (
          node2nixPkgs.graphql-language-service-cli.override {
            nativeBuildInputs = [ final.buildPackages.makeWrapper ];
            postInstall = ''
              wrapProgram "$out/bin/graphql-lsp" \
                --prefix NODE_PATH : ${nodePkgs.graphql}/lib/node_modules
            '';
          }
        );
      };

    orca-slicer =
      let
        pname = "orca-slicer";
        version = "2.1.1";
        src = final.fetchurl {
          url = "https://github.com/SoftFever/OrcaSlicer/releases/download/v${version}/OrcaSlicer_Linux_V${version}.AppImage";
          hash = "sha256-kvM1rBGEJhjRqQt3a8+I0o4ahB1Uc9qB+4PzhYoNQdM=";
        };
        appimageContents = final.appimageTools.extract { inherit pname version src; };
        inherit (final) lib;
      in
      lib.warnIf (lib.versionOlder version prev.orca-slicer.version)
        "orca-slicer is outdated. latest: ${prev.orca-slicer.version}"
        (
          final.appimageTools.wrapType2 {
            inherit pname version src;
            extraPkgs = pkgs: [ pkgs.webkitgtk ];
            extraInstallCommands = ''
              install -m 444 -D ${appimageContents}/OrcaSlicer.desktop $out/share/applications/OrcaSlicer.desktop
              install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/192x192/apps/OrcaSlicer.png \
                $out/share/icons/hicolor/192x192/apps/OrcaSlicer.png
              substituteInPlace $out/share/applications/OrcaSlicer.desktop \
                --replace-fail 'Exec=AppRun' 'Exec=env WEBKIT_DISABLE_DMABUF_RENDERER=1 ${pname}'
            '';
            passthru = {
              inherit appimageContents;
            };
          }
        );

    # disable xvfb-run tests to fix build on darwin
    xdot =
      (prev.xdot.overridePythonAttrs (oldAttrs: {
        nativeCheckInputs = [ ];
      })).overrideAttrs
        (oldAttrs: {
          doInstallCheck = false;
        });
  };
in
{
  additions =
    final: _prev:
    import ../pkgs {
      inherit inputs;
      pkgs = final;
    };

  modifications =
    final: prev:
    {
      #
    }
    // sharedModifications final prev;

  unstable-packages = stablePrev: stableFinal: {
    unstable = import inputs.nixpkgs-unstable {
      system = stableFinal.system;
      config.allowUnfree = true;
      overlays = [
        sharedModifications
        (final: prev: {
          # FIXME: https://github.com/NixOS/nixpkgs/pull/331856
          nix-du = warnIfOutdated prev.nix-du (
            stableFinal.nix-du.overrideAttrs (drv: rec {
              version = "1.2.1";

              src = final.fetchFromGitHub {
                owner = "symphorien";
                repo = "nix-du";
                rev = "v${version}";
                sha256 = "sha256-WImnfkBU17SFQG1DzVUdsNq3hkiISNjAVZr2xGbgwHg=";
              };

              cargoDeps = drv.cargoDeps.overrideAttrs (_: {
                inherit src;
                outputHash = "sha256-DjAi34ORO8z4K3qA9BOvLzMQIq2a2QiURiaFBVrK7WU=";
              });
            })
          );
        })
      ];
    };
  };
}
