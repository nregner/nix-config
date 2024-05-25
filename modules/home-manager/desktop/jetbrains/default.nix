{ config, ... }:
{
  home.file.".ideavimrc".source = config.lib.file.mkFlakeSymlink ./ideavimrc;
}
