{
  description = "static site auth";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";
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

      init_script = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default =
            pkgs.writeScript "runit" ''
              #!/usr/bin/env sh
              
              ${pkgs.copier}/bin/copier copy https://github.com/deej81/nix-project-template .
              # ${pkgs.copier}/bin/copier copy /home/deej/code/personal/nix-project-template .

              output_file="public_keys.txt"
              github_username=$(${pkgs.yq}/bin/yq -r '.github_username' .copier-answers.yml )
              public_keys=$(${pkgs.curl}/bin/curl -s "https://github.com/$github_username.keys")
              echo "$public_keys" >> "$output_file"

              echo "Public keys have been written to $output_file"

              ${pkgs.git}/bin/git init
              ${pkgs.git}/bin/git add .
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
