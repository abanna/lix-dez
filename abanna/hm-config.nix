{ config, pkgs, lib, inputs, ... }:
let
  vkwrap = pkg: (pkg.overrideAttrs (old: {
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
        echo "exec -a \"\$0\" ${inputs.nixGL.packages.${pkgs.system}.nixVulkanIntel}/bin/nixVulkanIntel $file \"\$@\"" >> "$out/bin/$(basename $file)"
        chmod +x "$out/bin/$(basename $file)"
      done
      shopt -u nullglob # Revert nullglob back to its normal default state
    '';
  }));

  # Wrap a single package
  glwrap = pkg: (pkg.overrideAttrs (old: {
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
        echo "exec -a \"\$0\" ${inputs.nixGL.packages.${pkgs.system}.nixGLDefault}/bin/nixGL $file \"\$@\"" >> "$out/bin/$(basename $file)"
        chmod +x "$out/bin/$(basename $file)"
      done
      shopt -u nullglob # Revert nullglob back to its normal default state
    '';
  }));

  wrapDeez = pkgs: builtins.map glwrap pkgs;
in
{
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

  home.shellAliases = {
    "cat" = "${lib.getExe pkgs.bat}";
    "catp" = "bat -p";
    "cz" = "chezmoi";
    "czg" = "chezmoi git";
    "dbox" = "distrobox";
    "g" = "git";
    "la" = "eza -lgah --icons --group-directories-first";
    "ls" = "eza -lgh --icons --group-directories-first";
    "lt" = "eza --tree";
    "nah" = "git reset --hard; git clean -df;";
    "reload" = "omz reload";
    "tf" = "terraform";
    "vi" = "nvim";
    "vim" = "nvim";

    ".j" = "just --justfile ~/.user.justfile --working-directory .";
    ".j~" = "just --justfile ~/.user.justfile --working-directory ~";
  };

  programs.atuin.enable = true;
  programs.atuin.enableBashIntegration = true;
  programs.atuin.flags = [ "--disable-up-arrow" ];
  programs.atuin.settings = {
    style = "compact";
    inline_height = 15;
  };

  #programs.bat.enable = true;
  programs.bat.config = { theme = "TwoDark"; };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza.enableBashIntegration = true;
  programs.eza.extraOptions = [ "--group-directories-first" "--header" ];
  programs.zoxide.enable = true;
  programs.fzf.enable = true;
  programs.bottom.enable = true;
  programs.jq.enable = true;
  #programs.lazygit.enable = true;
  programs.vscode = {
    enable = true;
    package = glwrap pkgs.vscode;
  };
  programs.ripgrep.enable = true;

  home.file.".p10k.zsh".text = ''
    # Powerlevel10k configuration
    POWERLEVEL10K_MODE='nerdfont-complete'
    POWERLEVEL10K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
    POWERLEVEL10K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time history time)
  '';

  programs = {
    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      localVariables = {
        POWERLEVEL10K_MODE = "nerdfont-complete";
        ZSH_THEME = "powerlevel10k/powerlevel10k";
      };
      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "zsh-autosuggestions";
          src = pkgs.zsh-autosuggestions;
          file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
        }
        {
          name = "zsh-fzf-tab";
          src = pkgs.zsh-fzf-tab;
          file = "share/fzf-tab/fzf-tab.zsh";
        }
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.zsh-syntax-highlighting;
          file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
        }
      ];

      oh-my-zsh = {
        enable = true;

        plugins = [
          "1password"
          "asdf"
          "aws"
          "docker"
          "fd"
          "fzf"
          "git"
          "golang"
          "jsontools"
          "kubectl"
          "minikube"
          "poetry"
          "pyenv"
          "python"
          "vagrant"
          "zsh-interactive-cd"
          "zsh-navigation-tools"
          "z"
          "zoxide"
        ];
      };
    };
  };

  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome;
    commandLineArgs = [
      "--ozone-platform=wayland"
    ];
  };


  home.packages =
    (wrapDeez (with pkgs; [
      _1password-gui
      jetbrains-toolbox
    ]))
    ++ (with pkgs; [
      # user selected packages
      debootstrap
      (inputs.nuspawn.packages.${pkgs.system}.nuspawn)
      (vkwrap zed-editor)
      helix
      ranger
      neovim
      _1password
      asdf-vm
      atuin
      bat
      bottom
      btop
      nushell
      cheat
      chezmoi
      distrobox
      docker
      podman
      eza
      fd
      fzf
      git
      github-cli
      just
      jq
      kubectl
      kind
      lazygit
      neofetch
      neovim
      nerdfonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      (pkgs.writeScriptBin "code.sh" "${glwrap pkgs.vscode}/bin/code --ozone-platform=wayland $@")
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
      navi
      nil
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
