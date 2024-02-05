{ inputs, pkgs, lib, ... }: {
  programs.alacritty = {
    enable = true;
    package = pkgs.unstable.alacritty;
    settings = {
      import = [ "${inputs.catppuccin-alacritty}/catppuccin-mocha.toml" ];
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
      keyboard.bindings = lib.optionals pkgs.stdenv.isDarwin (builtins.map
        (bind: {
          key = builtins.elemAt bind 0;
          mods = builtins.elemAt bind 1;
          chars = builtins.elemAt bind 2;
        }) [
          [ "A" "Alt" "\\u001Ba" ]
          [ "B" "Alt" "\\u001Bb" ]
          [ "C" "Alt" "\\u001Bc" ]
          [ "D" "Alt" "\\u001Bd" ]
          [ "E" "Alt" "\\u001Be" ]
          [ "F" "Alt" "\\u001Bf" ]
          [ "G" "Alt" "\\u001Bg" ]
          [ "H" "Alt" "\\u001Bh" ]
          [ "I" "Alt" "\\u001Bi" ]
          [ "J" "Alt" "\\u001Bj" ]
          [ "K" "Alt" "\\u001Bk" ]
          [ "L" "Alt" "\\u001Bl" ]
          [ "M" "Alt" "\\u001Bm" ]
          [ "N" "Alt" "\\u001Bn" ]
          [ "O" "Alt" "\\u001Bo" ]
          [ "P" "Alt" "\\u001Bp" ]
          [ "Q" "Alt" "\\u001Bq" ]
          [ "R" "Alt" "\\u001Br" ]
          [ "S" "Alt" "\\u001Bs" ]
          [ "T" "Alt" "\\u001Bt" ]
          [ "U" "Alt" "\\u001Bu" ]
          [ "V" "Alt" "\\u001Bv" ]
          [ "W" "Alt" "\\u001Bw" ]
          [ "X" "Alt" "\\u001Bx" ]
          [ "Y" "Alt" "\\u001By" ]
          [ "Z" "Alt" "\\u001Bz" ]
          [ "A" "Alt|Shift" "\\u001BA" ]
          [ "B" "Alt|Shift" "\\u001BB" ]
          [ "C" "Alt|Shift" "\\u001BC" ]
          [ "D" "Alt|Shift" "\\u001BD" ]
          [ "E" "Alt|Shift" "\\u001BE" ]
          [ "F" "Alt|Shift" "\\u001BF" ]
          [ "G" "Alt|Shift" "\\u001BG" ]
          [ "H" "Alt|Shift" "\\u001BH" ]
          [ "I" "Alt|Shift" "\\u001BI" ]
          [ "J" "Alt|Shift" "\\u001BJ" ]
          [ "K" "Alt|Shift" "\\u001BK" ]
          [ "L" "Alt|Shift" "\\u001BL" ]
          [ "M" "Alt|Shift" "\\u001BM" ]
          [ "N" "Alt|Shift" "\\u001BN" ]
          [ "O" "Alt|Shift" "\\u001BO" ]
          [ "P" "Alt|Shift" "\\u001BP" ]
          [ "Q" "Alt|Shift" "\\u001BQ" ]
          [ "R" "Alt|Shift" "\\u001BR" ]
          [ "S" "Alt|Shift" "\\u001BS" ]
          [ "T" "Alt|Shift" "\\u001BT" ]
          [ "U" "Alt|Shift" "\\u001BU" ]
          [ "V" "Alt|Shift" "\\u001BV" ]
          [ "W" "Alt|Shift" "\\u001BW" ]
          [ "X" "Alt|Shift" "\\u001BX" ]
          [ "Y" "Alt|Shift" "\\u001BY" ]
          [ "Z" "Alt|Shift" "\\u001BZ" ]
          [ "Key1" "Alt" "\\u001B1" ]
          [ "Key2" "Alt" "\\u001B2" ]
          [ "Key3" "Alt" "\\u001B3" ]
          [ "Key4" "Alt" "\\u001B4" ]
          [ "Key5" "Alt" "\\u001B5" ]
          [ "Key6" "Alt" "\\u001B6" ]
          [ "Key7" "Alt" "\\u001B7" ]
          [ "Key8" "Alt" "\\u001B8" ]
          [ "Key9" "Alt" "\\u001B9" ]
          [ "Key0" "Alt" "\\u001B0" ]
          [ "Space" "Control" "\\u0000" ] # Ctrl +Space
          [ "`" "Alt" "\\u001B`" ] # Alt +`
          [ "`" "Alt|Shift" "\\u001B~" ] # Alt +~
          [ "Period" "Alt" "\\u001B." ] # Alt +.
          [ "Key8" "Alt|Shift" "\\u001B*" ] # Alt +*
          [ "Key3" "Alt|Shift" "\\u001B#" ] # Alt +#
          [ "Period" "Alt|Shift" "\\u001B>" ] # Alt +>
          [ "Comma" "Alt|Shift" "\\u001B<" ] # Alt +<
          [ "Minus" "Alt|Shift" "\\u001B_" ] # Alt +_
          [ "Key5" "Alt|Shift" "\\u001B%" ] # Alt +%
          [ "Backslash" "Alt|Shift" "\\u001B|" ] # Alt +|```
        ]);
    };
  };
}
