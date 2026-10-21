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
      self,
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
          extraSpecialArgs ? { },
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
            dotfiles = self;
          }
          // extraSpecialArgs;
        }
        // {
          inherit username system;
        }
      );
      mkHomeConfigurations =
        {
          hosts,
          modules ? [ ],
        }:
        lib.mapAttrs' (
          host: args:
          let
            home = mkHomeConfig (args // { modules = modules ++ args.modules or [ ]; });
          in
          {
            name = "${home.username}@${host}";
            value = home;
          }
        ) hosts;
      mkSwitch =
        flake: system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          names = lib.attrNames (lib.filterAttrs (_: h: h.system == system) flake.homeConfigurations);
        in
        pkgs.writeShellApplication {
          name = "switch";
          runtimeInputs = [
            home-manager.packages.${system}.home-manager
            pkgs.coreutils
          ];
          text = ''
            homes=(${lib.escapeShellArgs names})
            host=$(uname -n)
            name="$USER@''${host%%.*}"
            if [[ $# -gt 0 && $1 != -* ]]; then
              name=$1
              [[ $name == *@* ]] || name="$USER@$name"
              shift
            fi

            # Prefer a literal hostname when both forms are configured.
            if [[ " ''${homes[*]} " != *" $name "* ]]; then
              host_hash=$(printf '%s' "''${name#*@}" | sha256sum)
              hashed_name="''${name%%@*}@sha256-''${host_hash%% *}"
              if [[ " ''${homes[*]} " == *" $hashed_name "* ]]; then
                name=$hashed_name
              fi
            fi

            if [[ " ''${homes[*]} " != *" $name "* ]]; then
              echo "No home named $name for ${system}." >&2
              if [[ ''${#homes[@]} -eq 0 || ! -t 0 ]]; then
                echo "Configured: ''${homes[*]:-none}" >&2
                exit 1
              fi
              PS3="Switch to which home? "
              name=
              select choice in "''${homes[@]}"; do
                [[ -n $choice ]] && name=$choice && break
              done
              [[ -n $name ]] || exit 1
            fi

            exec home-manager switch --flake "path:${flake}#$name" "$@"
          '';
        };
      mkSwitchApps =
        flake:
        lib.genAttrs systems (system: {
          switch = {
            type = "app";
            program = lib.getExe (mkSwitch flake system);
          };
        });
      # The modules the default home is built from. Other flakes build on
      # them with `lib.mkHomeConfigurations { modules = [ homeModules.default ]; ... }`.
      homeModule = {
        imports = [
          ./nix/home/default.nix
          ./nix/home/login-helper.nix
          ./nix/home/shell.nix
          ./nix/home/zsh.nix
          ./nix/home/gui.nix
          ./nix/hosts/mac.nix
          ./nix/pkgs/vim-euforia/vim-euforia.nix
          ./nix/development/python/default.nix
          ./nix/development/python/dontcheck.nix
          ./nix/development/ocaml/default.nix
        ];
      };
      hosts = {
        "sha256-30bbcf701f7daea5cc810123ec37531d9cc355bd8d26b4fef36e8695ef6eec2b" = {
          username = "dbueno";
          homeDirectory = "/Users/dbueno";
          modules = [ homeModule ];
          stateVersion = "24.11";
          system = "aarch64-darwin";
        };
      };
    in
    {
      overlays.default = overlay;

      homeModules.default = homeModule;

      lib = {
        # Builds a home from `modules` with this flake's nixpkgs, overlay and
        # special arguments, including `dotfiles` (this flake). Takes system,
        # homeDirectory, username, modules, stateVersion, and optionally
        # extraConfig and extraSpecialArgs.
        inherit mkHomeConfig;

        # Builds homeConfigurations from `hosts`, a set of mkHomeConfig
        # arguments keyed by short hostname (`uname -n` up to the first dot)
        # or "sha256-<hex SHA-256 of short hostname, without a newline>",
        # named "<username>@<host>". `modules` go before each host's own.
        inherit mkHomeConfigurations;

        # Takes a flake and gives its `apps`, where
        # `nix run .#switch [host] [home-manager args]` switches to the home in
        # its homeConfigurations for this machine's hostname, or the named
        # host, trying the literal name before its hash; with neither, it
        # offers this system's homes to pick from.
        inherit mkSwitchApps;
      };

      apps = mkSwitchApps self;

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

      homeConfigurations = mkHomeConfigurations { inherit hosts; };
    };
}
