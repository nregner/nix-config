let

  inherit (builtins) getFlake stringLength substring;
  currentSystem = builtins.currentSystem;
  flake = getFlake "/home/nregner/nix-config/iapetus";
  pkg = flake.packages.${currentSystem}."packages" or flake."packages";
  inherit (flake) outPath;
  outPathLen = stringLength outPath;
  sanitizePosition =
    { file, ... }@pos:
    assert substring 0 outPathLen file != outPath -> throw "${file} is not in ${outPath}";
    pos
    // {
      file =
        "/home/nregner/nix-config/iapetus" + substring outPathLen (stringLength file - outPathLen) file;
    };

  positionFromMeta =
    pkg:
    let
      parts = builtins.match "(.*):([0-9]+)" pkg.meta.position;
    in
    {
      file = builtins.elemAt parts 0;
      line = builtins.fromJSON (builtins.elemAt parts 1);
    };

  raw_version_position = sanitizePosition (builtins.unsafeGetAttrPos "version" pkg);

  position =
    if pkg ? meta.position then
      sanitizePosition (positionFromMeta pkg)
    else if pkg ? isRubyGem then
      raw_version_position
    else if pkg ? isPhpExtension then
      raw_version_position
    else
      sanitizePosition (builtins.unsafeGetAttrPos "src" pkg);
in
{
  name = pkg.name;
  old_version = pkg.version or (builtins.parseDrvName pkg.name).version;
  inherit raw_version_position;
  filename = position.file;
  line = position.line;
  urls = pkg.src.urls or null;
  url = pkg.src.url or null;
  rev = pkg.src.rev or null;
  hash = pkg.src.outputHash or null;
  go_modules = pkg.goModules.outputHash or null;
  go_modules_old = pkg.go-modules.outputHash or null;
  cargo_deps = pkg.cargoDeps.outputHash or null;
  raw_cargo_lock =
    if pkg ? cargoDeps.lockFile then
      let
        inherit (pkg.cargoDeps) lockFile;
        res = builtins.tryEval (sanitizePosition {
          file = toString lockFile;
        });
      in
      if res.success then res.value.file else false
    else
      null;
  composer_deps = pkg.composerRepository.outputHash or null;
  npm_deps = pkg.npmDeps.outputHash or null;
  pnpm_deps = pkg.pnpmDeps.outputHash or null;
  yarn_deps = pkg.offlineCache.outputHash or null;
  maven_deps = pkg.fetchedMavenDeps.outputHash or null;
  mix_deps = pkg.mixFodDeps.outputHash or null;
  tests = builtins.attrNames (pkg.passthru.tests or { });
  has_update_script = false;
  src_homepage = pkg.src.meta.homepage or null;
  changelog = pkg.meta.changelog or null;
  maintainers = pkg.meta.maintainers or null;
}
