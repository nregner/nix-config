{
  system = "aarch64-darwin";
  darwinConfigurations."enceladus".modules = [ ./configuration.nix ];
  homeConfigurations."nregner".modules = [ ./home.nix ];
}
