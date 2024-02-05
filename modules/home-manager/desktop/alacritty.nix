{ config, inputs, pkgs, lib, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      import = [ "${config.xdg.configHome}/alacritty/theme.yml" ];
      selection = { save_to_clipboard = true; };
      window = { dynamic_padding = true; };
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        size = 11;
      };
      env = { TERM = "alacritty"; };
      # https://github.com/alacritty/alacritty/issues/93#issuecomment-1364783147
      key_bindings = lib.optionals pkgs.stdenv.isDarwin (builtins.map (bind: {
        key = builtins.elemAt bind 0;
        mods = builtins.elemAt bind 1;
        chars = builtins.elemAt bind 2;
      }) [
        [ "A" "Alt" "\\x1ba" ]
        [ "B" "Alt" "\\x1bb" ]
        [ "C" "Alt" "\\x1bc" ]
        [ "D" "Alt" "\\x1bd" ]
        [ "E" "Alt" "\\x1be" ]
        [ "F" "Alt" "\\x1bf" ]
        [ "G" "Alt" "\\x1bg" ]
        [ "H" "Alt" "\\x1bh" ]
        [ "I" "Alt" "\\x1bi" ]
        [ "J" "Alt" "\\x1bj" ]
        [ "K" "Alt" "\\x1bk" ]
        [ "L" "Alt" "\\x1bl" ]
        [ "M" "Alt" "\\x1bm" ]
        [ "N" "Alt" "\\x1bn" ]
        [ "O" "Alt" "\\x1bo" ]
        [ "P" "Alt" "\\x1bp" ]
        [ "Q" "Alt" "\\x1bq" ]
        [ "R" "Alt" "\\x1br" ]
        [ "S" "Alt" "\\x1bs" ]
        [ "T" "Alt" "\\x1bt" ]
        [ "U" "Alt" "\\x1bu" ]
        [ "V" "Alt" "\\x1bv" ]
        [ "W" "Alt" "\\x1bw" ]
        [ "X" "Alt" "\\x1bx" ]
        [ "Y" "Alt" "\\x1by" ]
        [ "Z" "Alt" "\\x1bz" ]
        [ "A" "Alt|Shift" "\\x1bA" ]
        [ "B" "Alt|Shift" "\\x1bB" ]
        [ "C" "Alt|Shift" "\\x1bC" ]
        [ "D" "Alt|Shift" "\\x1bD" ]
        [ "E" "Alt|Shift" "\\x1bE" ]
        [ "F" "Alt|Shift" "\\x1bF" ]
        [ "G" "Alt|Shift" "\\x1bG" ]
        [ "H" "Alt|Shift" "\\x1bH" ]
        [ "I" "Alt|Shift" "\\x1bI" ]
        [ "J" "Alt|Shift" "\\x1bJ" ]
        [ "K" "Alt|Shift" "\\x1bK" ]
        [ "L" "Alt|Shift" "\\x1bL" ]
        [ "M" "Alt|Shift" "\\x1bM" ]
        [ "N" "Alt|Shift" "\\x1bN" ]
        [ "O" "Alt|Shift" "\\x1bO" ]
        [ "P" "Alt|Shift" "\\x1bP" ]
        [ "Q" "Alt|Shift" "\\x1bQ" ]
        [ "R" "Alt|Shift" "\\x1bR" ]
        [ "S" "Alt|Shift" "\\x1bS" ]
        [ "T" "Alt|Shift" "\\x1bT" ]
        [ "U" "Alt|Shift" "\\x1bU" ]
        [ "V" "Alt|Shift" "\\x1bV" ]
        [ "W" "Alt|Shift" "\\x1bW" ]
        [ "X" "Alt|Shift" "\\x1bX" ]
        [ "Y" "Alt|Shift" "\\x1bY" ]
        [ "Z" "Alt|Shift" "\\x1bZ" ]
        [ "Key1" "Alt" "\\x1b1" ]
        [ "Key2" "Alt" "\\x1b2" ]
        [ "Key3" "Alt" "\\x1b3" ]
        [ "Key4" "Alt" "\\x1b4" ]
        [ "Key5" "Alt" "\\x1b5" ]
        [ "Key6" "Alt" "\\x1b6" ]
        [ "Key7" "Alt" "\\x1b7" ]
        [ "Key8" "Alt" "\\x1b8" ]
        [ "Key9" "Alt" "\\x1b9" ]
        [ "Key0" "Alt" "\\x1b0" ]
        [ "Space" "Control" "\\x00" ] # Ctrl +Space
        [ "Grave" "Alt" "\\x1b`" ] # Alt +`
        [ "Grave" "Alt|Shift" "\\x1b~" ] # Alt +~
        [ "Period" "Alt" "\\x1b." ] # Alt +.
        [ "Key8" "Alt|Shift" "\\x1b*" ] # Alt +*
        [ "Key3" "Alt|Shift" "\\x1b#" ] # Alt +#
        [ "Period" "Alt|Shift" "\\x1b>" ] # Alt +>
        [ "Comma" "Alt|Shift" "\\x1b<" ] # Alt +<
        [ "Minus" "Alt|Shift" "\\x1b_" ] # Alt +_
        [ "Key5" "Alt|Shift" "\\x1b%" ] # Alt +%
        [ "Backslash" "Alt|Shift" "\\x1b|" ] # Alt +|```
      ]);
    };
  };

  xdg.configFile."alacritty/theme.yml".source =
    pkgs.runCommand "alacritty-theme" {
      nativeBuildInputs = [ pkgs.remarshal ];
    } ''
      remarshal ${inputs.catppuccin-alacritty}/catppuccin-mocha.toml -if toml -of yaml -o $out;
    '';
}
