{
  description = "";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixGL = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    astronvim = {
      url = "github:AstroNvim/template";
      flake = false;
    };
    nuspawn = {
        url = "https://codeberg.org/tulilirockz/nuspawn/archive/main.tar.gz";
    };
  };
  outputs =
    { self
    , nixpkgs
    , home-manager
    , astronvim
    , system-manager
    , nixGL
    , stylix
    , nuspawn
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
      ];
      forEachSupportedSystem =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f { pkgs = import nixpkgs { inherit system; }; });
    in
    {
      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt-rfc-style);

      homeConfigurations = rec {
        default = abanna;
        abanna = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit inputs;
          };
          modules = [
            stylix.homeManagerModules.stylix
            ./abanna
          ];
        };
      };

      systemConfigs.default =
      let
        pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
        };
      in system-manager.lib.makeSystemConfig {
            # nix run 'github:numtide/system-manager' -- switch --flake
            modules = [
                ./modules
                ({
                    config.system-manager.allowAnyDistro = true;
                })
            ];
        };
    };

}
