{
  description = "Nix Development Flake for Game of Active Directory (GOAD)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;

          # Allow unfree packages only for the unfree packages
          config.allowUnfreePredicate =
            pkg:
            builtins.elem (nixpkgs.lib.getName pkg) [
              "packer"
              "terraform"
              "vagrant"
            ];
        };

        makeProviderShellAndApp = provider: {
          # Build the devShell used with `nix develop`
          devShells.${provider.name} = pkgs.mkShell provider;

          # Build the application used with `nix run`
          apps.${provider.name} = {
            type = "app";
            program =
              let
                # Create the application in the store
                shellApplication = pkgs.writeShellApplication {
                  name = provider.name;
                  runtimeInputs = provider.packages;
                  text = ''
                    ${provider.shellHook}
                    exec ./goad.sh --provider ${provider.name} || true
                  '';
                };
              in
              # Use the application created to launch GOAD
              "${shellApplication}/bin/${provider.name}";
          };
        };
      in
      let
        defaultPackages = with pkgs; [
          wget
          unzip
          python310
        ];

        libvirtEnv = {
          name = "libvirt";
          packages =
            with pkgs;
            [
              vagrant
              qemu_kvm
              libvirt
              ebtables
              libguestfs
              ruby
            ]
            ++ defaultPackages;
          shellHook = ''
            # Vagrant plugins
            if command -v vagrant >/dev/null 2>&1; then
              for plugin in vagrant-reload winrm winrm-fs winrm-elevated; do
                vagrant plugin install "$plugin" || true
              done
            fi
          '';
        };

        vmwareEnv = {
          name = "vmware";
          packages =
            with pkgs;
            [
              vagrant
              ruby
            ]
            ++ defaultPackages;

          shellHook = ''
            # Vagrant plugins
            if command -v vagrant >/dev/null 2>&1; then
              for plugin in vagrant-reload vagrant-vmware-desktop winrm winrm-fs winrm-elevated; do
                vagrant plugin install "$plugin" || true
              done
            fi
          '';
        };

        virtualboxEnv = {
          name = "virtualbox";
          packages =
            with pkgs;
            [
              vagrant
              virtualbox
              ruby
            ]
            ++ defaultPackages;

          shellHook = ''
            # Vagrant plugins
            if command -v vagrant >/dev/null 2>&1; then
              for plugin in vagrant-reload vagrant-vbguest winrm winrm-fs winrm-elevated; do
                vagrant plugin install "$plugin" || true
              done
            fi
          '';
        };

        proxmoxEnv = {
          name = "proxmox";
          packages =
            with pkgs;
            [
              packer
              terraform
              sshpass
            ]
            ++ defaultPackages;
          shellHook = '''';
        };

        apps.default = {
          type = "app";
          program =
            let
              name = "goad-run-usage";
              shell = pkgs.writeShellApplication {
                name = name;
                text = ''
                  cat <<'USAGE'

                  Choose a provider, for example:

                  nix run .#libvirt
                  nix run .#virtualbox
                  nix run .#vmware
                  nix run .#proxmox

                  List available dev shells with:

                  nix flake show

                  USAGE
                  exit 1
                '';
              };
            in
            "${shell}/bin/${name}";
        };

        devShells.default = pkgs.mkShell {
          name = "goad-devshell-usage";
          shellHook = ''
            cat <<'USAGE'

            Choose a provider, for example:

              nix develop .#libvirt
              nix develop .#virtualbox
              nix develop .#vmware
              nix develop .#proxmox

            List available dev shells with:

              nix flake show

            USAGE
            exit 1
          '';
        };
      in
      let
        providers = [
          libvirtEnv
          vmwareEnv
          virtualboxEnv
          proxmoxEnv
        ];
        outputsList = map (p: makeProviderShellAndApp p) providers;

        merged = builtins.foldl' (acc: o: {
          devShells = acc.devShells // o.devShells;
          apps = acc.apps // o.apps;
        }) { inherit apps devShells; } outputsList;
      in
      merged
    );
}
