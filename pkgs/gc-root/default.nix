{ writeBabashkaApplication }:
writeBabashkaApplication {
  name = "gc-root";
  text = builtins.readFile ./gc-root.clj;
}
