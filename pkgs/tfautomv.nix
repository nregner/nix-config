{
  lib,
  buildGoModule,
  source,
}:
buildGoModule (
  source
  // {
    vendorHash = "sha256-BZ8IhVPxZTPQXBotFBrxV3dfwvst0te8R84I/urq3gY=";

    doCheck = false; # skip tests that require terraform, which is non-free

    meta = with lib; {
      description = "Generate Terraform moved blocks automatically for painless refactoring";
      homepage = "https://github.com/busser/tfautomv";
      license = licenses.asl20;
      # maintainers = with maintainers; [];
      mainProgram = "tfautomv";
    };
  }
)
