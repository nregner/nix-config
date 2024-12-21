# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  cura-x86_64-linux = {
    pname = "cura-x86_64-linux";
    version = "5.9.0";
    src = fetchurl {
      url = "https://github.com/Ultimaker/Cura/releases/download/5.9.0/UltiMaker-Cura-5.9.0-linux-X64.AppImage";
      sha256 = "sha256-STtVeM4Zs+PVSRO3cI0LxnjRDhOxSlttZF+2RIXnAp4=";
    };
  };
  flake-registry = {
    pname = "flake-registry";
    version = "02fe640c9e117dd9d6a34efc7bcb8bd09c08111d";
    src = fetchFromGitHub {
      owner = "nixos";
      repo = "flake-registry";
      rev = "02fe640c9e117dd9d6a34efc7bcb8bd09c08111d";
      fetchSubmodules = false;
      sha256 = "sha256-/3gigrEBFORQs6a8LL5twoHs7biu08y/8Xc5aQmk3b0=";
    };
    date = "2024-12-17";
  };
  hammerspoon = {
    pname = "hammerspoon";
    version = "1.0.0";
    src = fetchurl {
      url = "https://github.com/Hammerspoon/hammerspoon/releases/download/1.0.0/Hammerspoon-1.0.0.zip";
      sha256 = "sha256-XbcCtV2kfcMG6PWUjZHvhb69MV3fopQoMioK9+1+an4=";
    };
  };
  harper-ls = {
    pname = "harper-ls";
    version = "v0.12.0";
    src = fetchFromGitHub {
      owner = "elijah-potter";
      repo = "harper";
      rev = "v0.12.0";
      fetchSubmodules = false;
      sha256 = "sha256-2Frt0vpCGnF3pZREY+ynPkdCLf2zsde49cEsNrqFUtY=";
    };
  };
  hyprland-workspaces = {
    pname = "hyprland-workspaces";
    version = "v2.0.4";
    src = fetchFromGitHub {
      owner = "FieldofClay";
      repo = "hyprland-workspaces";
      rev = "v2.0.4";
      fetchSubmodules = false;
      sha256 = "sha256-a5P99aSqhlZqClXAoaUNv/jmuM5duLDf+OzMeKGwDVI=";
    };
  };
  joker = {
    pname = "joker";
    version = "v1.4.0";
    src = fetchFromGitHub {
      owner = "candid82";
      repo = "joker";
      rev = "v1.4.0";
      fetchSubmodules = false;
      sha256 = "sha256-Y7FaW3V80mXp3l87srTLyhF45MlNH7QUZ5hrTudPtDU=";
    };
  };
  kamp = {
    pname = "kamp";
    version = "v1.1.2";
    src = fetchFromGitHub {
      owner = "kyleisah";
      repo = "Klipper-Adaptive-Meshing-Purging";
      rev = "v1.1.2";
      fetchSubmodules = false;
      sha256 = "sha256-anBGjLtYlyrxeNVy1TEMcAGTVUFrGClLuoJZuo3xlDM=";
    };
  };
  linux-rockchip = {
    pname = "linux-rockchip";
    version = "709c51c64e1652d4f8c87b1815db86f56d188268";
    src = fetchFromGitHub {
      owner = "armbian";
      repo = "linux-rockchip";
      rev = "709c51c64e1652d4f8c87b1815db86f56d188268";
      fetchSubmodules = false;
      sha256 = "sha256-YZdWNhLopRyaEBojqMLMYEMKV6V0HcFgFmDbRSbBhRo=";
    };
    date = "2024-07-10";
  };
  mealie = {
    pname = "mealie";
    version = "latest";
    src = dockerTools.pullImage {
      imageName = "hkotel/mealie";
      imageDigest = "sha256:54a976880161c3c96de30b63cd0092d1f069aa8b23686669b726558ddf112724";
      sha256 = "sha256-LsnvoHhztvn/OrMLdyiLUwhkFn9OmVt2fWOUcK2QisY=";
      finalImageTag = "latest";
    };
  };
  orca-slicer-x86_64-linux = {
    pname = "orca-slicer-x86_64-linux";
    version = "v2.2.0";
    src = fetchurl {
      url = "https://github.com/SoftFever/OrcaSlicer/releases/download/v2.2.0/OrcaSlicer_Linux_v2.2.0.AppImage";
      sha256 = "sha256-3uqA3PXTrrOE0l8ziRAtmQ07gBFB+1Zx3S6JhmOPrZ8=";
    };
  };
  scroll-reverser = {
    pname = "scroll-reverser";
    version = "1.9";
    src = fetchurl {
      url = "https://github.com/pilotmoon/Scroll-Reverser/releases/download/v1.9/ScrollReverser-1.9.zip";
      sha256 = "sha256-CWHbtvjvTl7dQyvw3W583UIZ2LrIs7qj9XavmkK79YU=";
    };
  };
  sf-mono-nerd-font = {
    pname = "sf-mono-nerd-font";
    version = "v18.0d1e1.0";
    src = fetchFromGitHub {
      owner = "epk";
      repo = "SF-Mono-Nerd-Font";
      rev = "v18.0d1e1.0";
      fetchSubmodules = false;
      sha256 = "sha256-f5A/vTKCUxdMhCqv0/ikF46tRrx5yZfIkvfExb3/XEQ=";
    };
  };
}
