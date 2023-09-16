{ lib, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      font = { size = lib.mkForce 11; };
      selection = { save_to_clipboard = true; };
      window = { dynamic_padding = true; };
    };
  };

  stylix.targets.alacritty.enable = true;
}
