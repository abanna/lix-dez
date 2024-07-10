{ config, lib, pkgs, ... }:
{
    virtualization.docker.enable = true;
    nixpkgs.hostPlatform = "x86_64-linux";
    environment.systemPackages = with pkgs; [
        ripgrep
        fd
        htop
        gdu
    ];
}
