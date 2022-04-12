{
  description = "Denis Bueno's home-manager config";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    rusage.url = "https://github.com/dbueno/rusage/archive/main.tar.gz";
  };

  outputs = { self, nixpkgs, home-manager, rusage }:
    let
      lib = nixpkgs.lib;
      specialArgs = {
        # If you have flake outputs that need to be passed to submodules, put
        # them here.
        inherit rusage;
      };
      defaultUsername = "dbueno";
      emptyConfig = {...}: {};
      mkHomeConfig = lib.makeOverridable ({ system, homeDirectory, username ? defaultUsername, modules, stateVersion, extraConfig ? emptyConfig }:
        home-manager.lib.homeManagerConfiguration {
          inherit system homeDirectory username stateVersion;
          configuration = extraConfig;
          extraModules = modules;
          extraSpecialArgs = specialArgs;
        });
      slashUsersHost = { username ? defaultUsername, ... }@args: mkHomeConfig ({ homeDirectory = "/Users/${username}"; } // args );
      slashHomeHost = { username ? defaultUsername, ... }@args: mkHomeConfig ({ homeDirectory = "/home/${username}"; } // args );
      ascldapHost = { username ? defaultUsername, ... }@args: mkHomeConfig ({ homeDirectory = "/ascldap/${username}"; } // args );
      nfsHomeHost = { username ? defaultUsername, ... }@args: mkHomeConfig ({ homeDirectory = "/nfs-home/${username}"; } // args );
      hosts = {
        "GREATBELOW.local" = slashUsersHost {
          modules = [ ./shell.nix ./gui.nix ./darwin-host.nix ./my-email.nix ];
          stateVersion = "21.11";
          system = "x86_64-darwin";
        };
        "thinklappy" = slashHomeHost {
          modules = [ ./shell.nix ./gui.nix ./nixos-host.nix ./my-email.nix ];
          stateVersion = "21.11";
          system = "x86_64-linux";
        };
      };
    in
    {
      homeConfigurations = lib.mapAttrs' (hostname: config: { name = "${config.config.home.username}@${hostname}"; value = config; }) hosts;
    };

}
