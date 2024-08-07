{
  description = "lovesegfault's neovim configuration";

  inputs = {
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";

        devshell.follows = "";
        git-hooks.follows = "";
        home-manager.follows = "";
        nix-darwin.follows = "";
        nuschtosSearch.follows = "";
        treefmt-nix.follows = "";
      };
    };
  };

  outputs =
    { nixvim, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [
        inputs.git-hooks.flakeModule
      ];

      perSystem =
        { config, pkgs, system, ... }:
        let
          nixvimLib = nixvim.lib.${system};
          nixvim' = nixvim.legacyPackages.${system};
          nixvimModule = {
            inherit pkgs;
            module = import ./config; # import the module directly
            # You can use `extraSpecialArgs` to pass additional arguments to your module files
            extraSpecialArgs = {
              # inherit (inputs) foo;
            };
          };
          nvim = nixvim'.makeNixvimWithModule nixvimModule;
        in
        {
          devShells.default = pkgs.mkShell {
            name = "vim-config";
            nativeBuildInputs = with pkgs; [
              nil
              nixpkgs-fmt
              statix
            ];
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
              # treefmt.enable = true;
            };
          };

          checks.default = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;

          packages.default = nvim;
        };
    };
}
