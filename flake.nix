{
  description = "lovesegfault's neovim configuration";

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
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
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

      perSystem =
        { config, pkgs, system, self', ... }:
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
            nativeBuildInputs = with pkgs; [
              nil
              nixpkgs-fmt
              statix
              config.treefmt.build.wrapper
            ] ++ (builtins.attrValues config.treefmt.build.programs);

            shellHook = ''
              ${config.pre-commit.installationScript}
            '';
          };

          pre-commit = {
            check.enable = true;
            settings.hooks = {
              actionlint.enable = true;
              luacheck.enable = true;
              nil.enable = true;
              statix.enable = true;
              treefmt.enable = true;
            };
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixpkgs-fmt.enable = true;
              stylua.enable = true;
            };
          };

          packages = {
            default = self'.packages.neovim;
            neovim = nixvimPkgs.makeNixvimWithModule nixvimModule;
          };
        };
    };
}
