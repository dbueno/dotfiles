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
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      rusage,
      merjar,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      defaultUsername = "dbueno";
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
            overlays = [
              (final: prev: {
                rusage = rusage.defaultPackage.${system};
                merjar = merjar.defaultPackage.${system};
              })
              (
                final: prev:
                if !prev.stdenv.isLinux then
                  { }
                else
                  {
                  }
              )
            ];
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
      slashHomeHost =
        {
          username ? defaultUsername,
          ...
        }@args:
        mkHomeConfig ({ homeDirectory = "/home/${username}"; } // args);
      ascldapHost =
        {
          username ? defaultUsername,
          ...
        }@args:
        mkHomeConfig ({ homeDirectory = "/ascldap/${username}"; } // args);
      nfsHomeHost =
        {
          username ? defaultUsername,
          ...
        }@args:
        mkHomeConfig ({ homeDirectory = "/nfs-home/${username}"; } // args);
      hosts =
        let
          dev-modules = [
            ./development/python/default.nix
            ./development/python/dontcheck.nix
            ./development/ocaml/default.nix
          ];
        in
        {
          "NOTANYMORE" = slashUsersHost {
            username = "denbuen";
            modules = [
              ./home.nix
              ./login-helper.nix
              ./shell.nix
              ./zsh.nix
              ./gui.nix
              ./mac-host.nix
              ./pkgs/vim-euforia/vim-euforia.nix
            ] ++ dev-modules;
            stateVersion = "21.11";
            system = "aarch64-darwin";
          };
          "thinklappy" = slashHomeHost {
            modules = [
              ./home.nix
              ./login-helper.nix
              ./shell.nix
              ./zsh.nix
              ./gui.nix
              ./nixos-host.nix
              ./pkgs/vim-euforia/vim-euforia.nix
            ];
            stateVersion = "21.11";
            system = "x86_64-linux";
          };
        };
    in
    {
      homeConfigurations = lib.mapAttrs' (hostname: config: {
        name = "${config.username}@${hostname}";
        value = config;
      }) hosts;
    };
}
