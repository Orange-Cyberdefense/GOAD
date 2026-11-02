{
  description = "Nix Development Flake for Game of Active Directory (GOAD)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
      libvirtShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          vagrant
          qemu_kvm 
          libvirt
          ebtables 
          libguestfs
          ruby
          wget
          unzip
          python3
        ];
        shellHook = ''
          # Vagrant plugins
          if command -v vagrant >/dev/null 2>&1; then
            for plugin in vagrant-reload winrm winrm-fs winrm-elevated; do
                vagrant plugin install "$plugin" || true
            done
          fi
          # Set provider to libvirt
          if [ -z "$GOAD_SHELL_STARTED" ] && [ -x ./goad.sh ]; then
            export GOAD_SHELL_STARTED=1
            ./goad.sh --provider libvirt || true
          fi
        '';
      };
      vmwareShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          vagrant
          ruby
          wget
          unzip
          python3
        ];
        shellHook = ''
            # Vagrant plugins
          if command -v vagrant >/dev/null 2>&1; then
            for plugin in vagrant-reload vagrant-vmware-desktop winrm winrm-fs winrm-elevated; do
                vagrant plugin install "$plugin" || true
            done
          fi
          # Set provider to vmware
          if [ -z "$GOAD_SHELL_STARTED" ] && [ -x ./goad.sh ]; then
            export GOAD_SHELL_STARTED=1
            ./goad.sh --provider vmware || true
          fi
        '';
      };
      virtualboxShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          vagrant
          virtualbox
          ruby
          wget
          unzip
          python3
        ];
        shellHook = ''
          # Vagrant plugins
          if command -v vagrant >/dev/null 2>&1; then
            for plugin in vagrant-reload vagrant-vbguest winrm winrm-fs winrm-elevated; do
                vagrant plugin install "$plugin" || true
            done
          fi
          if [ -z "$GOAD_SHELL_STARTED" ] && [ -x ./goad.sh ]; then
            export GOAD_SHELL_STARTED=1
            ./goad.sh --provider virtualbox || true
          fi
        '';
      };
    in {
      devShells.${system} = {
        libvirt = libvirtShell;
        vmware = vmwareShell;
        virtualbox = virtualboxShell;
        default = pkgs.mkShell {
          name = "goad-devshell-usage";
          shellHook = ''
            cat <<'USAGE'

            Choose a provider, for example:

              nix develop .#libvirt
              nix develop .#virtualbox
              nix develop .#vmware

            List available dev shells with:

              nix flake show

            USAGE
            exit 1
          '';
        };
      };
    };
}