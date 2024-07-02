{ config, lib, pkgs, ... }:
{
    nixpkgs.hostPlatform = "x86_64-linux";

    environment =  {
        systemPackages =  with pkgs; [
            ripgrep
            fd
            htop
        ];
    };
    #virtualisation.docker.enable = true;
}
