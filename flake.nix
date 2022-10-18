{
  description = "Denis Bueno's home-manager config";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    rusage = {
      url = "https://github.com/dbueno/rusage/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, rusage }:
    let
      lib = nixpkgs.lib;
      defaultUsername = "dbueno";
      emptyConfig = {...}: {
        xdg.dataFile = {
          "hm-inputs/nixpkgs".source = nixpkgs;
          "hm-inputs/home-manager".source = home-manager;
        };
      };
      mkHomeConfig = lib.makeOverridable ({ system, homeDirectory, username ? defaultUsername, modules, stateVersion, extraConfig ? emptyConfig }:
      home-manager.lib.homeManagerConfiguration {
          modules = modules ++ [
            { home = { inherit username stateVersion homeDirectory; }; }
            extraConfig
          ];
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = {
            rusage = rusage.defaultPackage.${system};
          };
        });
      slashUsersHost = { username ? defaultUsername, ... }@args: mkHomeConfig ({ homeDirectory = "/Users/${username}"; } // args );
      slashHomeHost = { username ? defaultUsername, ... }@args: mkHomeConfig ({ homeDirectory = "/home/${username}"; } // args );
      ascldapHost = { username ? defaultUsername, ... }@args: mkHomeConfig ({ homeDirectory = "/ascldap/${username}"; } // args );
      nfsHomeHost = { username ? defaultUsername, ... }@args: mkHomeConfig ({ homeDirectory = "/nfs-home/${username}"; } // args );
      hosts = {
        "GREATBELOW.localdomain" = slashUsersHost {
          modules = [ ./shell.nix ./bash.nix ./gui.nix ./darwin-host.nix ./my-email.nix ];
          stateVersion = "21.11";
          system = "x86_64-darwin";
        };
        "thinklappy" = slashHomeHost {
          modules = [ ./shell.nix ./zsh.nix ./gui.nix ./nixos-host.nix ./my-email.nix ];
          stateVersion = "21.11";
          system = "x86_64-linux";
        };
      };
    in
    {
      homeConfigurations = lib.mapAttrs' (hostname: config: { name = "${config.config.home.username}@${hostname}"; value = config; }) hosts;
    };

}
