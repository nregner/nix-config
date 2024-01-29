{
  system = "x86_64-linux";
  nixosConfigurations.iapetus.modules = [ ./configuration.nix ];
  homeConfigurations."nregner@iapetus".modules = [ ./home.nix ];
}
