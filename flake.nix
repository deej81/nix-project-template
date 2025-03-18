{
  description = "static site auth";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
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
          init =
            pkgs.writeScript "runit" ''
              #!/usr/bin/env sh
              
              template_path="https://github.com/deej81/nix-project-template"

              # Check if argument "local" is passed
              if [ "$1" = "local" ]; then
                template_path="/home/deej/code/personal/nix-project-template"
                echo "Using local template at $template_path"
              else
                echo "Using remote template from $template_path"
              fi

              ${pkgs.copier}/bin/copier copy "$template_path" .

              include_vps=$(${pkgs.yq}/bin/yq -r '.include_vps' .copier-answers.yml )
              if [ "$include_vps" = "true" ]; then
                echo "Including VPS configuration"
                output_file="public_keys.txt"
                github_username=$(${pkgs.yq}/bin/yq -r '.github_username' .copier-answers.yml )
                public_keys=$(${pkgs.curl}/bin/curl -s "https://github.com/$github_username.keys")
                echo "$public_keys" >> "$output_file"

                echo "Public keys have been written to $output_file"

                echo "verifying private key presence"
                ${pkgs.python3}/bin/python3 infrastructure/tools/setup_private_key.py

                echo "enter an initial password for your user"
                ${pkgs.python3}/bin/python3 infrastructure/tools/set_user_password.py
                
              fi

              ${pkgs.git}/bin/git init
              ${pkgs.git}/bin/git add .
              '';

          update = pkgs.writeScript "runit" ''
              #!/usr/bin/env sh
              ${pkgs.copier}/bin/copier update
              '';

        }
      );

      apps = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          initialise = {
            type = "app";
            description = "Run Copier";
            program = "${self.init_script.${system}.init}";
          };
          update = {
            type = "app";
            description = "Update Copier";
            program = "${self.init_script.${system}.update}";
          };
        }
      );
    };
}
