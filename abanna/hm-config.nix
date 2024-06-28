{ config, pkgs, lib, inputs, ... }:
let

# Wrap a single package
  glwrap = pkg:  (pkg.overrideAttrs (old: {
    name = "nixGL-${pkg.name}";
    buildCommand = ''
      set -eo pipefail

      ${
      # Heavily inspired by https://stackoverflow.com/a/68523368/6259505
      pkgs.lib.concatStringsSep "\n" (map (outputName: ''
        echo "Copying output ${outputName}"
        set -x
        cp -rs --no-preserve=mode "${pkg.${outputName}}" "''$${outputName}"
        set +x
      '') (old.outputs or [ "out" ]))}

      rm -rf $out/bin/*
      shopt -s nullglob # Prevent loop from running if no files
      for file in ${pkg.out}/bin/*; do
        echo "#!${pkgs.bash}/bin/bash" > "$out/bin/$(basename $file)"
        echo "exec -a \"\$0\" ${lib.getExe inputs.nixGL.packages.${pkgs.system}.nixGLDefault} $file \"\$@\"" >> "$out/bin/$(basename $file)"
        chmod +x "$out/bin/$(basename $file)"
      done
      shopt -u nullglob # Revert nullglob back to its normal default state
    '';
  }));

  wrapDeez = pkgs: builtins.map glwrap pkgs;
in {
  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";
    image = ../amogus.jpg;
    base16Scheme = {
      # https://github.com/tinted-theming/schemes/blob/spec-0.11/base16/tokyo-city-terminal-dark.yaml
      base00 = "171D23";
      base01 = "1D252C";
      base02 = "28323A";
      base03 = "526270";
      base04 = "B7C5D3";
      base05 = "D8E2EC";
      base06 = "F6F6F8";
      base07 = "FBFBFD";
      base08 = "D95468";
      base09 = "FF9E64";
      base0A = "EBBF83";
      base0B = "8BD49C";
      base0C = "70E1E8";
      base0D = "539AFC";
      base0E = "B62D65";
      base0F = "DD9D82";
    };
  };
  targets.genericLinux.enable = true;
  home = {
    username = "gamer";
    homeDirectory = "/home/gamer";
  };
  programs.helix = {
    enable = true;
  };

  programs.git = {
    enable = true;
    diff-so-fancy.enable = true;
    userName = "abanna";
    userEmail = "alexanderbanna@gmail.com";
  };
  
 programs.gh.enable = true;
  programs.gh-dash.enable = config.programs.gh.enable;

  home.file = {
     ".user.justfile".source = ./user.justfile;
    ".config/nvim/init.lua".text = builtins.readFile "${inputs.astronvim.outPath}/init.lua";
    ".config/nvim/lua".source = "${inputs.astronvim.outPath}/lua";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = 
  (wrapDeez (with pkgs; [
    _1password-gui    
    jetbrains-toolbox
  ]))
  ++ (with pkgs; [
    # user selected packages
    helix
    ranger
    neovim
    _1password
    asdf-vm
    atuin
    bat
    bottom
    btop
    cascadia-code
    cheat
    chezmoi
    distrobox
    eza
    fd
    fzf
    git
    github-cli
    just
    jq
    kubectl
    lazygit
    neofetch
    neovim
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    proggyfonts
    oh-my-zsh
    pre-commit
    zsh-fzf-tab
    zsh-syntax-highlighting
    ranger
    ripgrep
    tldr
    terraform
    starship
    vscode
    xclip
    go
    gcc
    nodejs
    yarn
    yq-go
    rustup
    vhs
    duf
    lfs
    zellij
    zoxide
    zsh-powerlevel10k
    zsh-autosuggestions
    tre
    readline82
    pyenv
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
  ]);
}
