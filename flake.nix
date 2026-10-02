{
  description = "Denis Bueno's home-manager config";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    rusage = {
      url = "github:dbueno/rusage";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    merjar = {
      url = "github:dbueno/merjar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hm-login-shell-helper.url = "github:greedy/hm-login-shell-helper";
    # Scheme and template sources for tinty (the binary itself is pkgs.tinty).
    # Pinned here rather than let `tinty sync` clone them at activation time:
    # tinty symlinks an `[[items]].path` naming a local directory instead of
    # running git, so the whole theme set is reproducible and needs no network.
    tinted-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
    tinted-shell = {
      url = "github:tinted-theming/tinted-shell";
      flake = false;
    };
    tinted-vim = {
      url = "github:tinted-theming/tinted-vim";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      rusage,
      merjar,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      defaultUsername = "dbueno";
      overlay =
        final: _:
        let
          system = final.stdenv.hostPlatform.system;
        in
        {
          rusage = rusage.defaultPackage.${system};
          merjar = merjar.defaultPackage.${system};
          inherit (inputs) tinted-schemes tinted-shell tinted-vim;
        };
      emptyConfig =
        { ... }:
        {
          xdg.dataFile = {
            "hm-inputs/homepkgs".source = nixpkgs;
            "hm-inputs/home-manager".source = home-manager;
          };
          nix.registry.homepkgs.flake = nixpkgs;
        };
      mkHomeConfig = lib.makeOverridable (
        {
          system,
          homeDirectory,
          username ? defaultUsername,
          modules,
          stateVersion,
          extraConfig ? emptyConfig,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlay ];
          };
          modules = modules ++ [
            { home = { inherit username stateVersion homeDirectory; }; }
            extraConfig
          ];
          extraSpecialArgs = {
            inherit (inputs) hm-login-shell-helper;
          };
        }
        // {
          inherit username;
        }
      );
      slashUsersHost =
        {
          username ? defaultUsername,
          ...
        }@args:
        mkHomeConfig ({ homeDirectory = "/Users/${username}"; } // args);
      hosts =
        let
          dev-modules = [
            ./nix/development/python/default.nix
            ./nix/development/python/dontcheck.nix
            ./nix/development/ocaml/default.nix
          ];
        in
        {
          "NOTANYMORE" = slashUsersHost {
            username = "dbueno";
            modules = [
              ./nix/home/default.nix
              ./nix/home/login-helper.nix
              ./nix/home/shell.nix
              ./nix/home/zsh.nix
              ./nix/home/gui.nix
              ./nix/hosts/mac.nix
              ./nix/pkgs/vim-euforia/vim-euforia.nix
            ]
            ++ dev-modules;
            stateVersion = "24.11";
            system = "aarch64-darwin";
          };
        };
    in
    {
      overlays.default = overlay;

      formatter = lib.genAttrs systems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      devShells = lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nil
              nixd
            ];
          };
        }
      );

      homeConfigurations = lib.mapAttrs' (hostname: config: {
        name = "${config.username}@${hostname}";
        value = config;
      }) hosts;
    };
}
