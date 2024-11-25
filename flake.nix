{
  description = "lovesegfault's neovim configuration";

  nixConfig = {
    extra-trusted-substituters = [ "https://vim-config.cachix.org" ];
    extra-trusted-public-keys = [
      "vim-config.cachix.org-1:lebqx8RjL8pKLZIjCURKN91CB60vISuKpJboWSmjRJM="
    ];
  };

  inputs = {
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";

        devshell.follows = "";
        home-manager.follows = "";
        nix-darwin.follows = "";
        nuschtosSearch.follows = "";
      };
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];

        imports = [
          inputs.git-hooks.flakeModule
          inputs.treefmt-nix.flakeModule
        ];

        flake = {
          overlays.default = final: prev: {
            neovim-lovesegfault = self.packages.${final.stdenv.hostPlatform.system}.neovim;
          };
          githubActions =
            let
              githubSystems = [
                "x86_64-linux"
                "x86_64-darwin"
                "aarch64-darwin"
              ];
              ciPkgs = [ "neovim" ];

              checkDrvs = lib.getAttrs githubSystems self.checks;
              pkgDrvs = lib.genAttrs githubSystems (
                system: lib.genAttrs ciPkgs (pkg: self.packages.${system}.${pkg})
              );
            in
            inputs.nix-github-actions.lib.mkGithubMatrix {
              checks = lib.recursiveUpdate checkDrvs pkgDrvs;
            };
        };

        perSystem =
          {
            config,
            pkgs,
            system,
            self',
            ...
          }:
          let
            nixvimPkgs = inputs.nixvim.legacyPackages.${system};
            nixvimLib = inputs.nixvim.lib.${system};
            nixvimModule = {
              inherit pkgs;
              module = import ./config;
            };
          in
          {
            checks.nixvim = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;

            devShells.default = pkgs.mkShell {
              name = "vim-config";
              nativeBuildInputs =
                with pkgs;
                [
                  nil
                  nixfmt-rfc-style
                  statix
                  config.treefmt.build.wrapper
                ]
                ++ (builtins.attrValues config.treefmt.build.programs);

              shellHook = ''
                ${config.pre-commit.installationScript}
              '';
            };

            pre-commit = {
              check.enable = true;
              settings.hooks = {
                actionlint.enable = true;
                nil.enable = true;
                statix.enable = true;
                treefmt.enable = true;
              };
            };

            treefmt = {
              projectRootFile = "flake.nix";
              flakeCheck = false; # Covered by git-hooks check
              programs = {
                nixfmt-rfc-style.enable = true;
              };
            };

            packages = {
              default = self'.packages.neovim;
              neovim = nixvimPkgs.makeNixvimWithModule nixvimModule;

              # CI utils
              inherit (pkgs) cachix nix-fast-build;
            };
          };
      }
    );
}
