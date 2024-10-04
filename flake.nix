{
  description = "static site auth";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hardware.url = "github:nixos/nixos-hardware";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, ... } @ inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        }
      );
    in
    {

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      default = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in import ./shell.nix { inherit pkgs; }
      );

      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in import ./shell.nix { inherit pkgs; }
      );

      nixosConfigurations = {
        thinkpad = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            disko.nixosModules.disko
            {
              disko.devices.disk.main.device = "/dev/nvme0n1";
            }
            ./infrastructure/server/configuration.nix
            ./infrastructure/server/hardware/thinkpad/hardware-configuration.nix
          ];
        };

        qemuvm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            disko.nixosModules.disko
            {
              disko.devices.disk.main.device = "/dev/sda";
            }
            ./infrastructure/server/configuration.nix
            ./infrastructure/server/hardware/vm/hardware-configuration.nix
          ];
        };

        vmISO = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./infrastructure/server/hardware/custom-iso.nix
          ];
        };

      };

      init_script = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default =
            pkgs.writeScript "runit" ''
              #!/usr/bin/env sh
              ${pkgs.copier}/bin/copier copy https://github.com/deej81/nix-project-template .
            '';
        }
      );

      # Add an app to directly run copier
      apps = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          initialise = {
            type = "app";
            description = "Run Copier";
            # Define how copier will be run using nix run
            program = "${self.init_script.${system}.default}";
          };
        }
      );
    };
}
